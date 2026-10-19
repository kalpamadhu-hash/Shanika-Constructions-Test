import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const navy = Color(0xFF10243A);
const gold = Color(0xFFD6AE55);
const canvas = Color(0xFFF5F6FA);

void main() => runApp(const ShanikaApp());

class ShanikaApp extends StatelessWidget {
  const ShanikaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Shanika Constructions', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: navy), scaffoldBackgroundColor: canvas,
      appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white), floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: navy, foregroundColor: Colors.white),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: true)),
    home: const HomePage(),
  );
}

class Store {
  static Future<List<Map<String,dynamic>>> list(String key) async {
    final p = await SharedPreferences.getInstance(); final raw = p.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try { return (jsonDecode(raw) as List).map((e) => Map<String,dynamic>.from(e)).toList(); } catch (_) { return []; }
  }
  static Future<void> save(String key, List<Map<String,dynamic>> rows) async {
    final p = await SharedPreferences.getInstance(); await p.setString(key, jsonEncode(rows));
  }
}

class Module { final String key, title; final IconData icon; final List<String> fields; const Module(this.key,this.title,this.icon,this.fields); }
const modules = <Module>[
 Module('projects','Projects',Icons.apartment,['Project Number','Project Name','Customer','Phone','Site Location','Scheduled Date','Floor / Level','Notes','Status']),
 Module('scheduled','Scheduled Projects',Icons.event_available,['Schedule Number','Project Name','Customer','Phone','Site Location','Start Date','End Date','Estimated Amount','Reminder Date','Notes','Status']),
 Module('customers','Customer Contacts',Icons.people_alt,['Customer Name','Phone 1','Phone 2','Phone 3','Address','Site Location','Notes']),
 Module('bills','Customer Bills',Icons.receipt_long,['Bill Number','Project Number','Customer','Date','Floor / Level','Work Details','Amount (Rs.)','Amount Paid (Rs.)','Notes']),
 Module('workers','Workers & Wages',Icons.engineering,['Worker Name','Phone','Village / Address','NIC','Notes']),
 Module('masons','Mason / Baas Contacts',Icons.construction,['Name','Village','Phone 1','Phone 2','Notes']),
 Module('finance','Business Expenses & Income',Icons.account_balance_wallet,['Type (Income/Expense)','Category','Description','Amount (Rs.)','Date','Notes']),
 Module('project_costs','Project Costs',Icons.money_off,['Project Number','Type (Wages/Diesel/Small Purchase)','Description','Amount (Rs.)','Date','Notes']),
 Module('assets','Assets & Equipment',Icons.precision_manufacturing,['Asset Name','Purchase Date','Purchase Amount (Rs.)','Condition / Status','Maintenance Notes']),
 Module('savings','Daily Savings Tracking',Icons.savings,['Date','Amount Given (Rs.)','Returns / Withdrawals (Rs.)','Note']),
 Module('suppliers','Suppliers & Service Providers',Icons.store,['Category','Name / Shop','Phone 1','Phone 2','Address / Area','Materials / Service','Rate / Price','Notes']),
 Module('stock','Material Stock',Icons.inventory_2,['Material','Opening Quantity','Purchased Quantity','Used Quantity','Wastage Quantity','Unit','Notes']),
 Module('reports','Site Reports',Icons.photo_library,['Project Number','Report Date','Work Completed','Notes']),
 Module('letters','Letterhead Records',Icons.description,['Recipient Name / Address','Email','Phone','Date','Subject','Letter Body']),
 Module('cards','Visiting Card Details',Icons.badge,['Name','Title','Phone 1','Phone 2','Phone 3','Email','Location','Services','Tagline']),
];

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
 int tab=0;
 void openModule(Module m) { Navigator.pop(context); Navigator.push(context,MaterialPageRoute(builder:(_)=>m.key=='projects'?const ProjectsPage():m.key=='finance'?const FinancePage():m.key=='bills'?const BillsPage():m.key=='customers'?const CustomersPage():m.key=='scheduled'?const ScheduledPage():RecordPage(module:m))); }
 @override Widget build(BuildContext context) {
  final bottomPages=<Widget>[const DashboardPage(),const ProjectsPage(),const FinancePage()];
  return Scaffold(appBar:AppBar(title:const Text('Shanika Constructions'),actions:[IconButton(onPressed:()=>setState(()=>tab=0),icon:const Icon(Icons.home_outlined))]),
   drawer:Drawer(child:SafeArea(child:Column(children:[const Padding(padding:EdgeInsets.all(18),child:Row(children:[Icon(Icons.apartment,color:gold,size:32),SizedBox(width:10),Expanded(child:Text('SHANIKA CONSTRUCTIONS',style:TextStyle(fontWeight:FontWeight.bold,color:navy)))])),const Divider(),Expanded(child:ListView(children:[ListTile(leading:const Icon(Icons.dashboard),title:const Text('Dashboard'),onTap:(){Navigator.pop(context);setState(()=>tab=0);}),...modules.map((m)=>ListTile(leading:Icon(m.icon),title:Text(m.title),onTap:()=>openModule(m)),),ListTile(leading:const Icon(Icons.calculate),title:const Text('Concrete Calculator'),onTap:(){Navigator.pop(context);Navigator.push(context,MaterialPageRoute(builder:(_)=>const CalculatorPage()));}),ListTile(leading:const Icon(Icons.backup),title:const Text('Backup / Restore'),onTap:(){Navigator.pop(context);Navigator.push(context,MaterialPageRoute(builder:(_)=>const BackupPage()));})])),const Padding(padding:EdgeInsets.all(14),child:Text('Offline-first • Data stored on this phone',style:TextStyle(color:Colors.black54,fontSize:12)))]))),
   body:bottomPages[tab],bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[NavigationDestination(icon:Icon(Icons.dashboard_outlined),label:'Home'),NavigationDestination(icon:Icon(Icons.apartment),label:'Projects'),NavigationDestination(icon:Icon(Icons.account_balance_wallet_outlined),label:'Finance')]),
   floatingActionButton:tab==0?FloatingActionButton.extended(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const CalculatorPage())),icon:const Icon(Icons.calculate),label:const Text('Calculators')):null);
 }
}

class DashboardPage extends StatefulWidget { const DashboardPage({super.key}); @override State<DashboardPage> createState()=>_DashboardPageState(); }
class _DashboardPageState extends State<DashboardPage> {
 int projects=0,customers=0,workers=0,bills=0; double income=0,expenses=0;
 @override void initState(){super.initState();load();}
 Future<void> load()async{final p=await Store.list('projects'),c=await Store.list('customers'),w=await Store.list('workers'),b=await Store.list('bills'),f=await Store.list('finance');double inc=0,ex=0;for(final r in f){final v=num.tryParse('${r['Amount (Rs.)']??0}')?.toDouble()??0;if('${r['Type (Income/Expense)']}'.toLowerCase().contains('income'))inc+=v;else ex+=v;}if(mounted)setState((){projects=p.length;customers=c.length;workers=w.length;bills=b.length;income=inc;expenses=ex;});}
 @override Widget build(BuildContext context)=>RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(16),children:[Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[navy,Color(0xFF203F5B)]),borderRadius:BorderRadius.circular(22)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('BUILD • TRACK • GROW',style:TextStyle(color:gold,fontWeight:FontWeight.bold,letterSpacing:1.2)),SizedBox(height:10),Text('Construction Management',style:TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:8),Text('Projects, customer bills and site records — in one place.',style:TextStyle(color:Colors.white70))])),const SizedBox(height:16),GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,childAspectRatio:1.35,crossAxisSpacing:10,mainAxisSpacing:10,children:[_stat('Projects','$projects',Icons.apartment),_stat('Customers','$customers',Icons.people),_stat('Workers','$workers',Icons.engineering),_stat('Customer Bills','$bills',Icons.receipt_long)]),const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[const Align(alignment:Alignment.centerLeft,child:Text('Business finance entries',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17))),const SizedBox(height:10),_money('Income',income,Colors.green),_money('Expenses',expenses,Colors.red),const Divider(),_money('Recorded balance',income-expenses,navy)]))),const SizedBox(height:12),const Text('Use the menu to open all features. This starter version stores records on this phone.',style:TextStyle(color:Colors.black54))]));
 Widget _stat(String t,String v,IconData i)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Icon(i,color:gold),Text(v,style:const TextStyle(fontSize:21,fontWeight:FontWeight.bold,color:navy)),Text(t,style:const TextStyle(color:Colors.black54))])));
 Widget _money(String t,double v,Color c)=>Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(children:[Expanded(child:Text(t)),Text('Rs. ${v.toStringAsFixed(2)}',style:TextStyle(color:c,fontWeight:FontWeight.bold))]));
}

class ProjectsPage extends StatefulWidget { const ProjectsPage({super.key}); @override State<ProjectsPage> createState()=>_ProjectsPageState(); }
class _ProjectsPageState extends State<ProjectsPage>{List<Map<String,dynamic>> rows=[];bool loading=true;@override void initState(){super.initState();load();}Future<void> load()async{final r=await Store.list('projects');if(mounted)setState(()=>{rows=r,loading=false});}
 Future<void> edit([Map<String,dynamic>? old])async{final name=TextEditingController(text:'${old?['Project Name']??''}'),number=TextEditingController(text:'${old?['Project Number']??''}'),customer=TextEditingController(text:'${old?['Customer']??''}'),phone=TextEditingController(text:'${old?['Phone']??''}'),site=TextEditingController(text:'${old?['Site Location']??''}'),date=TextEditingController(text:'${old?['Scheduled Date']??DateTime.now().toIso8601String().substring(0,10)}'),floor=TextEditingController(text:'${old?['Floor / Level']??'Ground Floor'}'),notes=TextEditingController(text:'${old?['Notes']??''}');String status='${old?['Status']??'Active'}';final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(title:Text(old==null?'New Project':'Edit Project'),content:SizedBox(width:420,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[_field(name,'Project Name'),const SizedBox(height:9),_field(number,'Project Number (editable)'),const SizedBox(height:9),_field(customer,'Customer'),const SizedBox(height:9),_field(phone,'Phone'),const SizedBox(height:9),_field(site,'Site Location'),const SizedBox(height:9),_field(date,'Scheduled Date YYYY-MM-DD'),const SizedBox(height:9),DropdownButtonFormField<String>(value:['Ground Floor','1st Floor','2nd Floor','3rd Floor','Other'].contains(floor.text)?floor.text:'Ground Floor',decoration:const InputDecoration(labelText:'Floor / Level'),items:const ['Ground Floor','1st Floor','2nd Floor','3rd Floor','Other'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>floor.text=v??'Ground Floor'),const SizedBox(height:9),_field(notes,'Notes'),const SizedBox(height:9),DropdownButtonFormField<String>(value:status,decoration:const InputDecoration(labelText:'Status'),items:const ['Active','Completed','On hold','Cancelled'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setD(()=>status=v??'Active'))]))),actions:[
TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save Project'))])));
 if (ok == true && name.text.trim().isNotEmpty) { final numText = number.text.trim().isEmpty ? 'SC-${(rows.length + 1).toString().padLeft(3, '0')}' : number.text.trim(); final duplicate = rows.any((r) => r['Project Number'] == numText && r['internalId'] != old?['internalId']); if (duplicate) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This Project Number is already in use.'))); } } else { final item = <String, dynamic>{'internalId': old?['internalId'] ?? DateTime.now().microsecondsSinceEpoch.toString(), 'Project Number': numText, 'Project Name': name.text.trim(), 'Customer': customer.text.trim(), 'Phone': phone.text.trim(), 'Site Location': site.text.trim(), 'Scheduled Date': date.text.trim(), 'Floor / Level': floor.text.trim(), 'Notes': notes.text.trim(), 'Status': status, 'updatedAt': DateTime.now().toIso8601String()}; if (old == null) { rows.insert(0, item); } else { final i = rows.indexWhere((r) => r['internalId'] == old['internalId']); if (i >= 0) rows[i] = item; } await Store.save('projects', rows); if (mounted) setState(() {}); } }
 for(final c in [name,number,customer,phone,site,date,floor,notes]){c.dispose();}}
 Future<void> remove(int i)async{final yes=await confirmDelete(context);if(yes){rows.removeAt(i);await Store.save('projects',rows);if(mounted)setState((){});}}
 @override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.transparent,floatingActionButton:FloatingActionButton.extended(onPressed:()=>edit(),icon:const Icon(Icons.add),label:const Text('New Project')),body:loading?const Center(child:CircularProgressIndicator()):rows.isEmpty?const EmptyState(title:'No projects yet',hint:'Add your first construction project.'):ListView.builder(padding:const EdgeInsets.fromLTRB(12,12,12,90),itemCount:rows.length,itemBuilder:(ctx,i){final r=rows[i];return Card(child:ListTile(isThreeLine:true,leading:const CircleAvatar(backgroundColor:Color(0xFFFFF3D7),child:Icon(Icons.apartment,color:navy)),title:Text('${r['Project Number']} • ${r['Project Name']}',style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${r['Customer']??''}\n${r['Site Location']??''} • ${r['Floor / Level']??''}\n${r['Scheduled Date']??''} • ${r['Status']??''}'),trailing:PopupMenuButton<String>(onSelected:(v){if(v=='edit')edit(r);if(v=='delete')remove(i);},itemBuilder:(_)=>const[PopupMenuItem(value:'edit',child:Text('Edit')),PopupMenuItem(value:'delete',child:Text('Delete'))])));}));}

class CalculatorPage extends StatefulWidget{const CalculatorPage({super.key});@override State<CalculatorPage> createState()=>_CalculatorPageState();}
class _CalculatorPageState extends State<CalculatorPage> with SingleTickerProviderStateMixin{late TabController tabs;@override void initState(){super.initState();tabs=TabController(length:5,vsync:this);}@override void dispose(){tabs.dispose();super.dispose();}@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Concrete Calculator'),bottom:TabBar(controller:tabs,isScrollable:true,tabs:const[Tab(text:'Slab'),Tab(text:'Beam'),Tab(text:'Base Pit'),Tab(text:'Floor'),Tab(text:'Ready-Mix')])),body:TabBarView(controller:tabs,children:const[SlabCalc(),BeamCalc(),PitCalc(),FloorCalc(),ReadyMixCalc()]));}

class SlabCalc extends StatefulWidget{const SlabCalc({super.key});@override State<SlabCalc> createState()=>_SlabCalcState();}
class _SlabCalcState extends State<SlabCalc>{final area=TextEditingController(),thick=TextEditingController(text:'4'),bags=TextEditingController(),bagRate=TextEditingController();String floor='Ground Floor',grade='Grade 20 (1:2:4)',waste='5%';double volume=0,bagsEstimate=0,sand=0,metal=0,total=0;@override void dispose(){for(final c in [area,thick,bags,bagRate]){c.dispose();}super.dispose();}void calc(){final a=double.tryParse(area.text)??0,t=double.tryParse(thick.text)??0;final cubicFt=a*t/12;final dry=cubicFt*1.54*(1+(double.tryParse(waste.replaceAll('%',''))??0)/100);final parts=grade.contains('1:3:6')?[1.0,3.0,6.0]:grade.contains('1:1.5:3')?[1.0,1.5,3.0]:[1.0,2.0,4.0];final sum=parts.reduce((x,y)=>x+y);setState(()=>{volume=cubicFt/35.3147,bagsEstimate=dry*(parts[0]/sum)/1.225,sand=dry*(parts[1]/sum),metal=dry*(parts[2]/sum),total=(double.tryParse(bags.text)??0)*(double.tryParse(bagRate.text)??0)});}
 @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Slab & cement estimate',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:12),DropdownButtonFormField<String>(value:floor,decoration:const InputDecoration(labelText:'Floor / Level'),items:const['Ground Floor','1st Floor','2nd Floor','3rd Floor','Other'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>floor=v??floor)),const SizedBox(height:10),_field(area,'Slab area (sq ft)',numeric:true),const SizedBox(height:10),_field(thick,'Slab thickness (inches)',numeric:true),const SizedBox(height:10),DropdownButtonFormField<String>(value:grade,decoration:const InputDecoration(labelText:'Concrete Grade / Ratio'),items:const['Grade 15 (1:3:6)','Grade 20 (1:2:4)','Grade 25 (1:1.5:3)','Grade 30 (Mix Design අනුව)'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>grade=v??grade)),const SizedBox(height:10),DropdownButtonFormField<String>(value:waste,decoration:const InputDecoration(labelText:'Wastage'),items:
const['0%','5%','10%'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>waste=v??waste)),const SizedBox(height:10),_field(bags,'Cement bags (for customer bill)',numeric:true),const SizedBox(height:10),_field(bagRate,'Price per cement bag (Rs.)',numeric:true),const SizedBox(height:12),FilledButton.icon(onPressed:calc,icon:const Icon(Icons.calculate),label:const Text('Calculate estimate')),const SizedBox(height:12),_result('Selected floor',floor),_result('Concrete volume (rough)', '${volume.toStringAsFixed(3)} m³'),_result('Estimated cement bags (rough)',bagsEstimate.toStringAsFixed(1)),_result('Estimated sand', '${sand.toStringAsFixed(1)} cu ft'),_result('Estimated metal', '${metal.toStringAsFixed(1)} cu ft'),_result('Bill slab amount', 'Rs. ${total.toStringAsFixed(2)}'),const Padding(padding:EdgeInsets.only(top:10),child:Text('Material quantities are rough estimates only. Nominal ratios do not guarantee concrete grade; follow the approved structural mix design.',style:TextStyle(color:Colors.black54,fontSize:12)))]);}

class BeamCalc extends StatefulWidget{const BeamCalc({super.key});@override State<BeamCalc> createState()=>_BeamCalcState();}
class _BeamCalcState extends State<BeamCalc>{final length=TextEditingController(),thickness=TextEditingController(text:'3'),rate=TextEditingController();String beam='9 × 9';double sqft=0,amount=0;@override void dispose(){for(final c in [length,thickness,rate]){c.dispose();}super.dispose();}void calc(){final dims=beam.split('×').map((s)=>double.tryParse(s.trim())??0).toList();final l=double.tryParse(length.text)??0,t=double.tryParse(thickness.text)??0;final area=(dims[0]*dims[1]/12)/t*l;setState(()=>{sqft=area,amount=area*(double.tryParse(rate.text)??0)});}@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Beam area & rate',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:12),DropdownButtonFormField<String>(value:beam,decoration:const InputDecoration(labelText:'Beam size'),items:const['9 × 9','9 × 12','12 × 12'].map((x)=>DropdownMenuItem(value:x,child:Text('$x inches'))).toList(),onChanged:(v)=>setState(()=>beam=v??beam)),const SizedBox(height:10),_field(length,'Beam length (linear feet)',numeric:true),const SizedBox(height:10),_field(thickness,'Thickness (inches)',numeric:true),const SizedBox(height:10),_field(rate,'Rate per sq ft (Rs.)',numeric:true),const SizedBox(height:12),FilledButton.icon(onPressed:calc,icon:const Icon(Icons.calculate),label:const Text('Calculate')),const SizedBox(height:12),_result('Beam size','$beam inches'),_result('Calculated area','${sqft.toStringAsFixed(2)} sq ft'),_result('Total amount','Rs. ${amount.toStringAsFixed(2)}'),const Text('Formula follows your agreed method: (beam width × height ÷ 12) ÷ thickness × linear feet.',style:TextStyle(color:Colors.black54,fontSize:12))]);}

class PitCalc extends StatefulWidget{const PitCalc({super.key});@override State<PitCalc> createState()=>_PitCalcState();}
class _PitCalcState extends State<PitCalc>{final c33=TextEditingController(),r33=TextEditingController(),c44=TextEditingController(),r44=TextEditingController();double total=0;@override void dispose(){for(final c in [c33,r33,c44,r44]){c.dispose();}super.dispose();}void calc()=>setState(()=>total=(double.tryParse(c33.text)??0)*(double.tryParse(r33.text)??0)+(double.tryParse(c44.text)??0)*(double.tryParse(r44.text)??0));@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Base Pit Calculator',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:12),const Text('3′ × 3′ Base Pit',style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:8),_field(c33,'Number of pits',numeric:true),const SizedBox(height:8),_field(r33,'Price per pit (Rs.)',numeric:true),const Divider(height:28),const Text('4′ × 4′ Base Pit',style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:8),_field(c44,'Number of pits',numeric:true),const SizedBox(height:8),_field(r44,'Price per pit (Rs.)',numeric:true),const SizedBox(height:12),FilledButton.icon(onPressed:calc,icon:const Icon(Icons.calculate),label:const Text('Calculate total')),const SizedBox(height:12),_result('Total Base Pit amount','Rs. ${total.toStringAsFixed(2)}')]);}

class FloorCalc extends StatefulWidget{const FloorCalc({super.key});@override State<FloorCalc> createState()=>_FloorCalcState();}
class _FloorCalcState extends State<FloorCalc>{final area=TextEditingController(),rate=TextEditingController(),custom=TextEditingController();String? thick='4';bool manual=false;double total=0;@override void dispose(){for(final c in [area,rate,custom]){c.dispose();}super.dispose();}void calc()=>setState(()=>total=(double.tryParse(area.text)??0)*(double.tryParse(rate.text)??0));@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Floor Calculator',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:12),_field(area,'Floor area (sq ft)',numeric:true),const SizedBox(height:10),const Text('Thickness (tick one)'),Wrap(spacing:8,runSpacing:0,children:['1','2','3','4','5','6'].map((v)=>ChoiceChip(label:Text('$v″'),selected:!manual&&thick==v,onSelected:(_)=>setState(()=>{manual=false,thick=v}))).toList()),CheckboxListTile(value:manual,onChanged:(v)=>setState(()=>manual=v??false),title:const Text('More than 6 inches — enter manually'),contentPadding:EdgeInsets.zero),if(manual)_field(custom,'Custom thickness (inches)',numeric:true),const SizedBox(height:10),_field(rate,'Rate per sq ft (Rs.)',numeric:true),const SizedBox(height:12),FilledButton.icon(onPressed:calc,icon:const Icon(Icons.calculate),label:const Text('Calculate amount')),const SizedBox(height:12),_result('Thickness',manual?'${custom.text} inches':'$thick inches'),_result('Floor area','${double.tryParse(area.text)??0} sq ft'),_result('Total amount','Rs. ${total.toStringAsFixed(2)}')]);}

class ReadyMixCalc extends StatefulWidget{const ReadyMixCalc({super.key});@override State<ReadyMixCalc> createState()=>_ReadyMixCalcState();}
class _ReadyMixCalcState extends State<ReadyMixCalc>{final qty=TextEditingController(),rate=TextEditingController(),transport=TextEditingController();String floor='Ground Floor';bool includeTransport=false;double total=0;@override void dispose(){for(final c in [qty,rate,transport]){c.dispose();}super.dispose();}void calc()=>setState(()=>total=(double.tryParse(qty.text)??0)*(double.tryParse(rate.text)??0)+(includeTransport?(double.tryParse(transport.text)??0):0));@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Ready-Mix Calculator',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:navy)),const SizedBox(height:12),DropdownButtonFormField<String>(value:floor,decoration:const InputDecoration(labelText:'Floor / Level'),items:const['Ground Floor','1st Floor','2nd Floor','3rd Floor','Other'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>floor=v??floor)),const SizedBox(height:10),_field(qty,'Concrete quantity (m³)',numeric:true),const SizedBox(height:10),_field(rate,'Price per m³ (Rs.)',numeric:true),CheckboxListTile(value:includeTransport,onChanged:(v)=>setState(()=>includeTransport=v??false),title:const Text('Add transport charge'),contentPadding:EdgeInsets.zero),if(includeTransport)_field(transport,'Transport charge (Rs.)',numeric:true),const SizedBox(height:12),FilledButton.icon(onPressed:calc,icon:const Icon(Icons.calculate),label:const Text('Calculate total')),const SizedBox(height:12),_result('Selected floor',floor),_result('Ready-Mix amount','Rs. ${((double.tryParse(qty.text)??0)*(double.tryParse(rate.text)??0)).toStringAsFixed(2)}'),_result('Total including selected transport','Rs. ${total.toStringAsFixed(2)}'),const Text('Calculator result does not automatically post to project costs or customer bills.',style:TextStyle(color:Colors.black54,fontSize:12))]);}

class BillsPage extends StatefulWidget{const BillsPage({super.key});@override State<BillsPage> createState()=>_BillsPageState();}
class _BillsPageState extends State<BillsPage>{List<Map<String,dynamic>> rows=[];bool loading=true;@override void initState(){super.initState();load();}Future<void> load()async{final r=await Store.list('bills');if(mounted)setState(()=>{rows=r,loading=false});}Future<void> add()async{final cs=List.generate(10,(_)=>TextEditingController());const labels=['Document Type (Quotation / Actual Bill)','Bill Number','Project Number','Customer','Date','Floor / Level','Work Details','Amount (Rs.)','Amount Paid (Rs.)','Notes'];final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Issue customer bill'),content:SizedBox(width:420,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:List.generate(labels.length,(i)=>Padding(padding:const EdgeInsets.only(bottom:9),child:_field(cs[i],labels[i],numeric:i==7||i==8)))))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save Bill'))]));if(ok==true&&cs[3].text.trim().isNotEmpty){rows.insert(0,{for(var i=0;i<labels.length;i++)labels[i]:cs[i].text.trim(),'created':DateTime.now().toIso8601String()});await Store.save('bills',rows);if(mounted)setState((){});}for(final c in cs){c.dispose();}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Customer Bills')),floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.add),label:const Text('Issue Bill')),body:loading?const Center(child:CircularProgressIndicator()):rows.isEmpty?const EmptyState(title:'No customer bills',hint:'Issue a bill with the floor, work details and customer amount.'):ListView.builder(padding:const EdgeInsets.all(12),itemCount:rows.length,itemBuilder:(ctx,i){final r=rows[i];final due=(double.tryParse('${r['Amount (Rs.)']}')??0)-(double.tryParse('${r['Amount Paid (Rs.)']}')??0);return Card(child:ListTile(isThreeLine:true,leading:const Icon(Icons.receipt_long,color:gold),title:Text('${r['Document Type (Quotation / Actual Bill)']} • ${r['Bill Number']} • ${r['Customer']}',style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('Project ${r['Project Number']} • ${r['Floor / Level']}\n${r['Work Details']}\nTotal Rs. ${r['Amount (Rs.)']} • Balance Rs. ${due.toStringAsFixed(2)}')));}));}

class CustomersPage extends StatefulWidget{const CustomersPage({super.key});@override State<CustomersPage> createState()=>_CustomersPageState();}
class _CustomersPageState extends State<CustomersPage>{List<Map<String,dynamic>> rows=[];bool loading=true;@override void initState(){super.initState();load();}Future<void> load()async{final r=await Store.list('customers');if(mounted)setState(()=>{rows=r,loading=false});}Future<void> add()async{final cs=List.generate(7,(_)=>TextEditingController());const labels=['Customer Name','Phone 1','Phone 2','Phone 3','Address','Site Location','Notes'];final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Customer contact'),content:SizedBox(width:400,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:List.generate(labels.length,(i)=>Padding(padding:const EdgeInsets.only(bottom:8),child:_field(cs[i],labels[i])))))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save'))]));if(ok==true&&cs[0].text.trim().isNotEmpty){rows.insert(0,{for(var i=0;i<labels.length;i++)labels[i]:cs[i].text.trim()});await Store.save('customers',rows);if(mounted)setState((){});}for(final c in cs){c.dispose();}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Customer Contacts')),floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.person_add),label:const Text('Add Customer')),body:loading?const Center(child:CircularProgressIndicator()):rows.isEmpty?const EmptyState(title:'No customers',hint:'Save customers once and reuse their contact details.'):ListView.builder(padding:const EdgeInsets.all(12),itemCount:rows.length,itemBuilder:(ctx,i){final r=rows[i];return Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text('${r['Customer Name']}'),subtitle:Text('${r['Phone 1']??''} • ${r['Site Location']??''}\n${r['Address']??''}'),isThreeLine:true,trailing:PopupMenuButton<String>(onSelected:(v)async{if(v=='delete'){final yes=await confirmDelete(context);if(yes){rows.removeAt(i);await Store.save('customers',rows);if(mounted)setState((){});}}},itemBuilder:(_)=>const[PopupMenuItem(value:'delete',child:Text('Delete'))])));}));}

class ScheduledPage extends StatefulWidget{const ScheduledPage({super.key});@override State<ScheduledPage> createState()=>_ScheduledPageState();}
class _ScheduledPageState extends State<ScheduledPage>{List<Map<String,dynamic>> rows=[];bool loading=true;@override void initState(){super.initState();load();}Future<void> load()async{final r=await Store.list('scheduled');if(mounted)setState(()=>{rows=r,loading=false});}Future<void> add()async{final cs=List.generate(11,(_)=>TextEditingController());const labels=['Schedule Number','Project Name','Customer','Phone','Site Location','Start Date','End Date','Estimated Amount','Reminder Date','Notes','Status'];final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Schedule future project'),content:SizedBox(width:420,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:List.generate(labels.length,(i)=>Padding(padding:const EdgeInsets.only(bottom:8),child:_field(cs[i],labels[i],numeric:i==7)))))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save Schedule'))]));if(ok==true&&cs[1].text.trim().isNotEmpty){if(cs[0].text.trim().isEmpty)cs[0].text='SC-S-${(rows.length+1).toString().padLeft(3,'0')}';rows.insert(0,{for(var i=0;i<labels.length;i++)labels[i]:cs[i].text.trim()});await Store.save('scheduled',rows);if(mounted)setState((){});}for(final c in cs){c.dispose();}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Scheduled Projects')),floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.event),label:const Text('Schedule Project')),body:loading?const Center(child:CircularProgressIndicator()):rows.isEmpty?const EmptyState(title:'No scheduled projects',hint:'Add upcoming accepted jobs and dates here.'):ListView.builder(padding:const EdgeInsets.all(12),itemCount:rows.length,itemBuilder:(ctx,i){final r=rows[i];return Card(child:ListTile(isThreeLine:true,title:Text('${r['Schedule Number']} • ${r['Project Name']}'),subtitle:Text('${r['Customer']} • ${r['Site Location']}\n${r['Start Date']} to ${r['End Date']}\nReminder: ${r['Reminder Date']}'),trailing:PopupMenuButton<String>(onSelected:(v)async{if(v=='convert'){final projects=await Store.list('projects');final id=DateTime.now().microsecondsSinceEpoch.toString();projects.insert(0,{'internalId':id,'Project Number':'SC-${(projects.length+1).toString().padLeft(3,'0')}','Project Name':r['Project Name'],'Customer':r['Customer'],'Phone':r['Phone'],'Site Location':r['Site Location'],'Scheduled Date':r['Start Date'],'Floor / Level':'Ground Floor','Notes':r['Notes'],'Status':'Active'});await Store.save('projects',projects);rows.removeAt(i);await Store.save('scheduled',rows);if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Converted to a real project.')));}}else if(v=='delete'){final yes=await confirmDelete(context);if(yes){rows.removeAt(i);await Store.save('scheduled',rows);if(mounted)setState((){});}}},itemBuilder:(_)=>const[PopupMenuItem(value:'convert',child:Text('Convert to Project')),PopupMenuItem(value:'delete',child:Text('Delete Schedule'))])));}));}

class FinancePage extends StatefulWidget{const FinancePage({super.key});@override State<FinancePage> createState()=>_FinancePageState();}
class _FinancePageState extends State<FinancePage>{List<Map<String,dynamic>> rows=[];bool loading=true;@override void initState(){super.initState();load();}Future<void> load()async{final r=await Store.list('finance');if(mounted)setState(()=>{rows=r,loading=false});}Future<void> add()async{final desc=TextEditingController(),amount=TextEditingController(),cat=TextEditingController();String type='Expense';final ok=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(title:const Text('Add finance entry'),content:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<String>(value:type,decoration:const InputDecoration(labelText:'Type'),items:const['Income','Expense'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setD(()=>type=v??'Expense')),const SizedBox(height:8),_field(cat,'Category'),const SizedBox(height:8),_field(desc,'Description'),const SizedBox(height:8),_field(amount,'Amount (Rs.)',numeric:true)]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save'))])));if(ok==true&&desc.text.trim().isNotEmpty){rows.insert(0,{'Type (Income/Expense)':type,'Category':cat.text,'Description':desc.text,'Amount (Rs.)':double.tryParse(amount.text)??0,'Date':DateTime.now().toIso8601String().substring(0,10)});await Store.save('finance',rows);if(mounted)setState((){});}for(final c in [desc,amount,cat]){c.dispose();}}
 @override Widget build(BuildContext context){double inc=0,ex=0;for(final r in rows){final v=num.tryParse('${r['Amount (Rs.)']??0}')?.toDouble()??0;if(r['Type (Income/Expense)']=='Income')inc+=v;else ex+=v;}return Scaffold(appBar:AppBar(title:const Text('Business Finance')),floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.add),label:const Text('Add Entry')),body:loading?const Center(child:CircularProgressIndicator()):Column(children:[Card(margin:const EdgeInsets.all(12),child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[_summary('Income',inc,Colors.green),_summary('Expenses',ex,Colors.red),const Divider(),_summary('Balance',inc-ex,navy)]))),Expanded(child:rows.isEmpty?const EmptyState(title:'No finance entries',hint:'Add income or expense entries for your business.'):ListView.builder(padding:const EdgeInsets.fromLTRB(12,0,12,90),itemCount:rows.length,itemBuilder:(ctx,i){final r=rows[i];final income=r['Type (Income/Expense)']=='Income';return Card(child:ListTile(leading:Icon(income?Icons.south_west:Icons.north_east,color:income?Colors.green:Colors.red),title:Text('${r['Description']}'),subtitle:Text('${r['Category']} • ${r['Date']}'),trailing:Text('Rs. ${r['Amount (Rs.)']}',style:TextStyle(color:income?Colors.green:Colors.red,fontWeight:FontWeight.bold))));}))]));}
 Widget _summary(String s,double v,Color c)=>Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(children:[Expanded(child:Text(s)),Text('Rs. ${v.toStringAsFixed(2)}',style:TextStyle(color:c,fontWeight:FontWeight.bold))]));}

class RecordPage extends StatefulWidget {
  final Module module;
  const RecordPage({super.key, required this.module});
  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  String query = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final r = await Store.list(widget.module.key);
    if (mounted) setState(() { rows = r; loading = false; });
  }

  Future<void> edit([Map<String, dynamic>? old]) async {
    final cs = widget.module.fields
        .map((f) => TextEditingController(text: '${old?[f] ?? ''}'))
        .toList();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(old == null ? 'Add ${widget.module.title}' : 'Edit ${widget.module.title}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.module.fields.length, (i) {
                final f = widget.module.fields[i];
                final numeric = f.toLowerCase().contains('amount') ||
                    f.toLowerCase().contains('quantity') ||
                    f.toLowerCase().contains('rate') ||
                    f.toLowerCase().contains('price');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _field(cs[i], f, numeric: numeric),
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      final item = <String, dynamic>{
        'internalId': old?['internalId'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        'createdAt': old?['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      for (var i = 0; i < widget.module.fields.length; i++) {
        item[widget.module.fields[i]] = cs[i].text.trim();
      }
      if (old == null) {
        rows.insert(0, item);
      } else {
        final index = rows.indexWhere((r) => r['internalId'] == old['internalId']);
        if (index >= 0) rows[index] = item;
      }
      await Store.save(widget.module.key, rows);
      if (mounted) setState(() {});
    }
    for (final c in cs) { c.dispose(); }
  }

  Future<void> remove(Map<String, dynamic> row) async {
    if (await confirmDelete(context)) {
      rows.remove(row);
      await Store.save(widget.module.key, rows);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = rows.where((r) => r.values.any((v) => '$v'.toLowerCase().contains(query.toLowerCase()))).toList();
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => edit(), icon: const Icon(Icons.add), label: const Text('Add record')),
      body: loading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search records'),
            onChanged: (v) => setState(() => query = v))),
          Expanded(child: filtered.isEmpty
            ? EmptyState(title: 'No ${widget.module.title.toLowerCase()}', hint: 'Tap Add record to save your first entry.')
            : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final r = filtered[i];
                final fields = widget.module.fields;
                final first = fields.isEmpty ? 'Record' : '${r[fields.first] ?? 'Record'}';
                final lines = fields.skip(1).where((f) => '${r[f] ?? ''}'.trim().isNotEmpty).take(5).map((f) => '$f: ${r[f]}').join('\n');
                return Card(child: ListTile(
                  isThreeLine: true,
                  title: Text(first, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(lines),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) { if (v == 'edit') edit(r); if (v == 'delete') remove(r); },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}

const backupKeys = <String>[
  'projects', 'scheduled', 'customers', 'bills', 'workers', 'masons', 'finance',
  'project_costs', 'assets', 'savings', 'suppliers', 'stock', 'reports', 'letters', 'cards'
];

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});
  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final importController = TextEditingController();
  bool busy = false;
  String info = 'Create a backup before changing phones or reinstalling the app.';

  @override
  void dispose() { importController.dispose(); super.dispose(); }

  Future<void> exportBackup() async {
    setState(() { busy = true; info = 'Preparing backup…'; });
    try {
      final data = <String, dynamic>{
        'app': 'Shanika Constructions',
        'formatVersion': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'records': <String, dynamic>{},
      };
      final records = data['records'] as Map<String, dynamic>;
      for (final key in backupKeys) { records[key] = await Store.list(key); }
      final jsonText = const JsonEncoder.withIndent('  ').convert(data);
      await Clipboard.setData(ClipboardData(text: jsonText));
      if (mounted) setState(() { info = 'Backup JSON copied to clipboard. Paste it into a text file and save it somewhere safe. Keep the full text; do not edit it.'; });
    } catch (e) {
      if (mounted) setState(() { info = 'Backup failed: $e'; });
    } finally { if (mounted) setState(() { busy = false; }); }
  }

  Future<void> importBackup() async {
    Map<String, dynamic> decoded;
    try {
      final raw = jsonDecode(importController.text.trim());
      if (raw is! Map<String, dynamic> || raw['app'] != 'Shanika Constructions' || raw['formatVersion'] != 1 || raw['records'] is! Map) {
        throw const FormatException('This does not look like a supported Shanika Constructions backup.');
      }
      decoded = Map<String, dynamic>.from(raw['records'] as Map);
      for (final key in backupKeys) {
        if (decoded[key] != null && decoded[key] is! List) throw FormatException('Invalid records for $key');
      }
    } catch (e) {
      setState(() { info = 'Cannot restore: $e'; });
      return;
    }
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Restore this backup?'),
      content: const Text('This replaces the saved records on this phone with the backup. First export a backup of the current phone if you need to keep its records.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Replace records'))],
    ));
    if (yes != true) return;
    setState(() { busy = true; info = 'Restoring records…'; });
    try {
      for (final key in backupKeys) {
        final value = decoded[key];
        if (value is List) await Store.save(key, value.map((e) => Map<String, dynamic>.from(e as Map)).toList());
        else await Store.save(key, <Map<String, dynamic>>[]);
      }
      if (mounted) setState(() { info = 'Restore completed. Return to Home and reopen a section to refresh its records.'; });
    } catch (e) {
      if (mounted) setState(() { info = 'Restore stopped with an error: $e'; });
    } finally { if (mounted) setState(() { busy = false; }); }
  }

  Future<void> pasteClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && mounted) setState(() { importController.text = data!.text!; info = 'Clipboard text loaded. Check it, then tap Restore backup.'; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Backup / Restore')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Icon(Icons.backup_outlined, size: 52, color: gold),
      const SizedBox(height: 12),
      const Text('Protect your records', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Backup copies your app records as JSON text. Save that text in a file or a trusted cloud location. Restore replaces records on this phone.'),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: busy ? null : exportBackup, icon: const Icon(Icons.copy), label: const Text('Create backup & copy JSON')),
      const SizedBox(height: 18),
      const Text('Restore from backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: busy ? null : pasteClipboard, icon: const Icon(Icons.content_paste), label: const Text('Paste backup from clipboard')),
      const SizedBox(height: 8),
      TextField(controller: importController, minLines: 4, maxLines: 8, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Paste the complete backup JSON here')),
      const SizedBox(height: 8),
      FilledButton.tonalIcon(onPressed: busy ? null : importBackup, icon: const Icon(Icons.restore), label: const Text('Restore backup')),
      if (busy) const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator())),
      const SizedBox(height: 12),
      Text(info, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 10),
      const Text('Important: clearing app data or uninstalling may remove records. Export a backup regularly and test it before relying on it for business records.', style: TextStyle(color: Colors.redAccent)),
    ]),
  );
}

class EmptyState extends StatelessWidget{final String title,hint;const EmptyState({super.key,required this.title,required this.hint});@override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.inbox_outlined,size:54,color:Colors.grey.shade400),const SizedBox(height:12),Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:6),Text(hint,textAlign:TextAlign.center,style:const TextStyle(color:Colors.black54))])));}
Widget _field(TextEditingController c,String label,{bool numeric=false})=>TextField(controller:c,keyboardType:numeric?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,decoration:InputDecoration(labelText:label));
Widget _result(String label,String value)=>Card(child:Padding(padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),child:Row(children:[Expanded(child:Text(label)),Flexible(child:Text(value,textAlign:TextAlign.end,style:const TextStyle(fontWeight:FontWeight.bold,color:navy)))])));
Future<bool> confirmDelete(BuildContext context)async=>await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Delete record?'),content:const Text('This cannot be undone.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Delete'))]))??false;

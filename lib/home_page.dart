import 'package:db_exp/db_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget{

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  DbHelper dbHelper = DbHelper.getInstance();
  List<Map<String,dynamic>> mData = [];
  String dueDate = "";
  DateFormat dtFormat = DateFormat.MMMMEEEEd();


  @override
  void initState(){
    super.initState();

    dbHelper.fetchNote();
    getNotes();

  }

  void getNotes() async{
    mData = await dbHelper.fetchNote();
    setState(() {

    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: mData.isNotEmpty ? ListView.builder(
          itemCount: mData.length,
          itemBuilder:(_,index){
        return ListTile(
          leading: SizedBox(width:70,
              child: Row(
                children: [
                  Text("${index+1}",style:TextStyle(fontSize: 18),),
                  Checkbox(value: mData[index][DbHelper.NOTE_CHECKED] == 1 , onChanged: (value) async{

                    bool check = await dbHelper.updateStatus(id:mData[index][DbHelper.NOTE_COLUMN_ID], isChecked: value!);

                    if(check){
                      getNotes();
                    }
                  }),
                  
                ],
              )),
          title: Text(mData[index][DbHelper.NOTE_COLUMN_TITLE],style:mData[index][DbHelper.NOTE_CHECKED]==1 ?const TextStyle(color: Colors.grey,decoration:TextDecoration.lineThrough,decorationColor:Colors.grey): const TextStyle(color: Colors.black),),
          subtitle: Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Text(mData[index][DbHelper.NOTE_COLUMN_DESC],style:mData[index][DbHelper.NOTE_CHECKED]==1 ?const TextStyle(color: Colors.grey,decoration:TextDecoration.lineThrough,decorationColor:Colors.grey): const TextStyle(color: Colors.black),),
              Text(
                  dtFormat.format(DateTime.fromMillisecondsSinceEpoch
                (int.parse(mData[index][DbHelper.NOTE_COLUMN_CREATED_AT])))),
              
               Text(dtFormat.format(DateTime.fromMillisecondsSinceEpoch
                 (int.parse(mData[index][DbHelper.NOTE_COMPLETE_AT])))),
            ],
          ),
          trailing: SizedBox( width:100,
            child: Row(
              children: [
                IconButton(onPressed: () async{

                  titleController.text = mData[index][DbHelper.NOTE_COLUMN_TITLE];
                  descController.text = mData[index][DbHelper.NOTE_COLUMN_DESC];

                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(40))
                      ),
                      enableDrag: false,
                      //   isDismissible: false,
                      context: context, builder: (_){
                    return getBottomSheetUI(isUpdate: true,nID: mData[index]["n_id"]);
                  });

                }, icon: Icon(Icons.edit)),

                IconButton(onPressed: ()async{

                  bool check = await dbHelper.deleteNote(id: mData[index]["n_id"]);
                  if(check){
                    getNotes();
                  }

                }, icon: Icon(Icons.delete,color: Colors.red,)),


              ],
            ),
          ),

        );
      }) :
      Center(child: Text("No Data Yet!!"),),
     /* floatingActionButton: FloatingActionButton(
        onPressed: () async{
          bool check = await dbHelper.addNote(title: "My Note", desc: "Today was a Fantastic day as everyday");
          getNotes();
          if(check){
            print("Note added Scussfully");
          }else{
            print("Failed to add");
          }
        },
        child: Icon(Icons.add),
      ),*/

      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          titleController.clear();
          descController.clear();

        showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40))
          ),
            enableDrag: false,
         //   isDismissible: false,
            context: context, builder: (_){
          return getBottomSheetUI();
        });
        },
        child: Icon(Icons.add),
      ),


    );
  }

  Widget getBottomSheetUI({bool isUpdate = false,int nID = 0}){
    return Container(
      padding: EdgeInsets.all(11),
      width: double.infinity,
      height: 500,

      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40))
      ),
      child: Column(
        children: [
          Text(isUpdate?"Update Note":"Add Note",style: TextStyle(fontSize: 21),),
          SizedBox(height: 11,),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              label: Text("Title"),
              hintText: "Enter your title here..",
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder:OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          SizedBox(height: 15,),
          TextField(
            controller: descController,
            minLines: 4,
            maxLines: 4,
            decoration: InputDecoration(
              label: Text("Desc"),
              hintText: "Enter your description here..",
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder:OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          SizedBox(height: 11,),
          OutlinedButton(onPressed: () async{

           DateTime? selectedDate = await showDatePicker(context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(9999));

           print(selectedDate!.millisecondsSinceEpoch.toString());

           dueDate = selectedDate!.millisecondsSinceEpoch.toString();

          }, child: Text("Choose Date")),
          SizedBox(height: 21,),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () async {

                if(titleController.text.isNotEmpty &&
                    descController.text.isNotEmpty){

                  bool check =false;
                  if(isUpdate){

                    check = await dbHelper.updateNote(title: titleController.text,
                        desc: descController.text, id: nID);

                  }
                  else {
                    check = await dbHelper.addNote(
                        title: titleController.text.toString(),
                        desc: descController.text.toString(),
                        dueDateAt: dueDate,
                        );

                  }
                  if (check){
                    Navigator.pop(context);
                    getNotes();
                  }
                }

                else {

                }

              }, child: Text(isUpdate ? "Update" : "Add")),
              SizedBox(width: 11,),
              OutlinedButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Cancel")),
            ],
          ),

        ],
      ),

    );
  }

}
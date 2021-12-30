import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled/use_provider.dart';

class MyFile extends StatefulWidget
{
  _MyFile createState ()=> _MyFile();
}

class _MyFile extends State<MyFile>
{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //   print("sasasasa");
        //
        //   //addInSqlLite();
        //
        //
        //   List<Map> list = await db.rawQuery('SELECT * FROM DATA');
        //   print(list);
        //
        //
        //   },
        // ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(

            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20)
                ),
                child: TextFormField(
                  controller: _search,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'title';
                //     }
                //     // else if(!isEmail(value!)){
                //     //   return 'please enter valid email';
                //     // }
                //
                //     return null;
                //   },

                  onChanged: (val){

                    context.read<Search>().setSearch(val);
                    // setState(() {
                    //   searchIndex = val;
                    // });
                   // print(val);
                  },
                  style: const TextStyle(
                      color: Colors.black,
                     // fontSize: 20/scaleFactor,
                      fontWeight: FontWeight.bold
                  ),

                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                        Icons.search,
                      color: Colors.grey,
                    ),
                    hintText: "search with display name",
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2,
                            color: Colors.grey),
                        //borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                        //borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 2,
                            color: Colors.grey)
                    ),
                  ),
                ),
              ),

              FutureBuilder(
                future: http.get(url),
                builder: (BuildContext context, AsyncSnapshot<Response> snapshot) {
                  if(snapshot.hasData)
                  {
                    var jd = jsonDecode(snapshot.data!.body) as Map;

                    List data = jd['tags'];

                    return Consumer<Search>(builder: (context,todo,child){
                      return Column(
                        children: data.map((e){
                          if(todo.search == "")
                          {
                            return getContainer(e);
                          }
                          else{
                            //print(e['displayName'].toString().substring(0,searchIndex.length));
                            if(todo.search.length <= e['displayName'].toString().length)
                            {
                              if(e['displayName'].toString().substring(0,todo.search.length).toLowerCase() == todo.search.toLowerCase())
                              {
                                return getContainer(e);
                              }
                              else{
                                return Container();
                              }
                            }
                            else{
                              return Container();
                            }

                          }

                        }).toList(),
                      );
                    }); Column(
                      children: data.map((e){
                        if(searchIndex == "")
                        {
                          return getContainer(e);
                        }
                        else{
                          //print(e['displayName'].toString().substring(0,searchIndex.length));
                          if(searchIndex.length <= e['displayName'].toString().length)
                          {
                            if(e['displayName'].toString().substring(0,searchIndex.length) == searchIndex)
                            {
                              return getContainer(e);
                            }
                            else{
                              return Container();
                            }
                          }
                          else{
                            return Container();
                          }

                        }

                      }).toList(),
                    );
                  }
                  else{
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget getContainer(Map data)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 5,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(15),


          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Material(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "${data['title']}",
                    style: const TextStyle(
                        color: Colors.deepPurple,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15,),

              Container(
                padding: EdgeInsets.all(2),
                child: Text(
                    "${data['displayName']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),


              SizedBox(height: 5,),

              Container(
                padding: EdgeInsets.all(2),
                child: Text("${data['description']}"),
              ),

              SizedBox(height: 5,),

              Container(
                padding: EdgeInsets.all(2),
                child: Text(
                    "${data['meta']}",
                  style: const TextStyle(
                      color: Colors.deepPurple,
                  ),
                ),
              ),

            ],
          ),

        ),
      ),
    );
  }

  @override
  void initState() {
    addInSqlLite();
  }


  Future<void> addInSqlLite()
  async {
    db = await openDatabase('my_db.db',version: 1,onCreate: (Database db,int version) async {

      });

    db.transaction((txn) async {
      await txn.execute("DROP TABLE DATA").then((value){
        print("done");

      });
    });

    db.execute("CREATE TABLE IF NOT EXISTS DATA (ID TEXT PRIMARY KEY,TITLE TEXT,DISPLAYNAME TEXT,DESCRIPTION TEXT,META TEXT)").then((value){


      print("create");
      http.get(url).then((value) {
        var jd = jsonDecode(value.body) as Map;

        print(jd);
        List data = jd['tags'];
        print(data);

        data.forEach((e) {
          db.transaction((txn) async {
            await txn.rawInsert(
                'INSERT INTO DATA("ID","TITLE","DISPLAYNAME","DESCRIPTION","META") VALUES("${e['_id']}","${e['title']}","${e['displayName']}","${e['description']}","${e['meta']}")')
                .then((value) {
              print(value);
            });
          });
        });
      });







    }).catchError((onError)=>print("sasakn $onError"));




    // List<Map> list = await db.rawQuery('SELECT * FROM DATA');
      //
      // print(list);

    //db.query(table)
   // print(db);
  }

  late Database db;
  String searchIndex = "";
  Uri url = Uri.parse('https://sigmatenant.com/mobile/tags');
  TextEditingController _search = TextEditingController();
}
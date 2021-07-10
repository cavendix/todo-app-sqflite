part of 'pages.dart';

class HomePage extends StatefulWidget {
  final GoogleSignInAccount user;
  
  HomePage({
    Key key,
    this.user,
  }) : super(key: key);



  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Todo>> _todoList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _todoList = DatabaseHelper.instance.getTodoList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Container(
        child: Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Hallo!',
                    style: primaryTextStyle.copyWith(fontSize: 20),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    widget.user.displayName,
                    style: primaryTextStyle.copyWith(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    widget.user.email,
                    style: primaryTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildTask(Todo todo) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            ListTile(
              title: Text(
                todo.title,
                style: primaryTextStyle.copyWith(
                    fontSize: 18,
                    decoration: todo.status == 0
                        ? TextDecoration.none
                        : TextDecoration.lineThrough),
              ),
              subtitle: Text(
                '${_dateFormatter.format(todo.date)}',
                style: primaryTextStyle.copyWith(
                    fontSize: 15,
                    decoration: todo.status == 0
                        ? TextDecoration.none
                        : TextDecoration.lineThrough),
              ),
              trailing: Checkbox(
                
                onChanged: (value) {
                  todo.status = value ? 1 : 0;
                  DatabaseHelper.instance.updateTodo(todo);
                  _updateTaskList();
                },
                activeColor: primaryColor,
                value: todo.status == 1 ? true : false,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTodoPage(
                    updateTodoList: _updateTaskList(),
                    todo: todo,
                  ),
                ),
              ),
            ),
            Divider(),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor1,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTodoPage(
              updateTodoList: _updateTaskList,
            )),
          );
        },
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _todoList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final int completedTodoCount = snapshot.data
                .where((Todo todo) => todo.status == 1)
                .toList()
                .length;

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 20),
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            header(),

                            ///Logout Button
                            TextButton(
                              style: TextButton.styleFrom(),
                              onPressed: () async {
                                await GoogleSignInApi.logout();

                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => SignInPage(),
                                ));
                              },
                              child: Text(
                                'Logout',
                                style: primaryTextStyle.copyWith(
                                    fontSize: 12,
                                    fontWeight: medium,
                                    color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'My TODO Lists',
                          style: primaryTextStyle.copyWith(fontSize: 20),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '$completedTodoCount of ${snapshot.data.length}',
                          style: subtitleTextStyle,
                        ),
                      ],
                    ),
                  );
                }
                return _buildTask(snapshot.data[index - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qoute_app/core/helper/icon_broken.dart';
import 'package:qoute_app/logic/cubit/home_cubit.dart';

class BottomBarCustom extends StatelessWidget {
  const BottomBarCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xff1c1c1c),
            blurRadius: 30,
            offset: Offset(8, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xff1c1c1c),
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
          currentIndex: BlocProvider.of<HomeCubit>(context).currentIndexPage,
          onTap: (index) {
            BlocProvider.of<HomeCubit>(context).togglePages(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.shirt, size: 20),
              label: 'Wardrope',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.wand_stars_inverse),
              label: 'Generate',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.create),
              label: 'Design',
            ),
            BottomNavigationBarItem(
              icon: Icon(IconBroken.Heart),
              label: 'Favourit',
            ),
          ],
        ),
      ),
    );
  }
}

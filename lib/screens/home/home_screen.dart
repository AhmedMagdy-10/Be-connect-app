import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qoute_app/logic/cubit/home_cubit.dart';
import 'package:qoute_app/logic/cubit/home_states_cubit.dart';
import 'package:qoute_app/screens/home/widgets/bottom_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStatesCubit>(
      builder:
          (context, state) => Scaffold(
            body:
                BlocProvider.of<HomeCubit>(
                  context,
                ).pages[BlocProvider.of<HomeCubit>(context).currentIndexPage],

            bottomNavigationBar: BlocBuilder<HomeCubit, HomeStatesCubit>(
              builder: (context, state) => BottomBarCustom(),
            ),
          ),
    );
  }
}

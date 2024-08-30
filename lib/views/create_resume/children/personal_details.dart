import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:resume_builder_app/models/TemplateDataModel.dart';
import 'package:resume_builder_app/utils/routes/app_colors.dart';
import 'package:resume_builder_app/views/create_resume/state/create_resume_state.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:resume_builder_app/views/widgets/bg_gradient_color.dart';
import 'package:resume_builder_app/views/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/pop_ups/custom_popups.dart';
class PersonalDetails extends ConsumerStatefulWidget {
  PersonalDetails({super.key});


  @override
  ConsumerState<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends ConsumerState<PersonalDetails> {
  late TextEditingController fullName;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController country;
  late TextEditingController currentPosition;
  late TextEditingController address;
  late TextEditingController street;
  late TextEditingController bio;

  @override
  void initState() {
    fullName=TextEditingController(text: ref.read(templateDataModel).fullName);
    email=TextEditingController(text: ref.read(templateDataModel).email);
    phone=TextEditingController(text: ref.read(templateDataModel).phoneNumber);
    country=TextEditingController(text: ref.read(templateDataModel).country);
    currentPosition=TextEditingController(text: ref.read(templateDataModel).currentPosition);
    address=TextEditingController(text: ref.read(templateDataModel).address);
    street=TextEditingController(text: ref.read(templateDataModel).street);
    bio=TextEditingController(text: ref.read(templateDataModel).bio);
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar().build(context, "Personal Details"),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal:  12.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h,),
              Text("Photo",style: Theme.of(context).textTheme.headlineMedium,),
              SizedBox(
                height: 8.h,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 100.h,
                    width: 100.h,
                    child: Card(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.sp)
                      ),
                      child: Icon(Icons.person,color: Colors.white,size: 60.sp,),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: (){},
                          style: ButtonStyle(
                              backgroundColor:const  WidgetStatePropertyAll<Color>(AppColors.primaryColor),
                              shape:WidgetStatePropertyAll<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.sp)
                                  )
                              )
                          ),
                          child: Text("Add",style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),),
                        ),
                        ElevatedButton(
                          onPressed: (){},
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(Colors.orange),
                              shape:WidgetStatePropertyAll<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.sp)
                                  )
                              )
                          ),
                          child: Text("Change",style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 12.h,
              ),
              textCard('Name', "Enter Full Name",Icons.person,fullName),
              SizedBox(
                height: 12.h,
              ),
              textCard('Email', "Email Address",Icons.email,email),
              SizedBox(
                height: 12.h,
              ),
              textCard('Phone', "Phone Number",Icons.phone,phone),
              SizedBox(
                height: 12.h,
              ),
              textCard('Country', "Country Name",Icons.flight,country),
              SizedBox(
                height: 12.h,
              ),
              textCard('Current Position', "Enter Designation",Icons.account_box_rounded,currentPosition),
              SizedBox(
                height: 12.h,
              ),
              textCard('Street', "House Number, Street",Icons.location_on_rounded,street,maxLines: 3),
              SizedBox(
                height: 12.h,
              ),
              textCard('Address', "City/Town, State",Icons.location_on_rounded,address,maxLines: 3),
              SizedBox(
                height: 12.h,
              ),
              textCard('Bio', "Enter Something About you",Icons.location_on_rounded,bio,maxLines: 5),
              SizedBox(
                height: 24.h,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: BgGradientColor(
        borderRadius: BorderRadius.circular(30.sp),
        child: IconButton(onPressed: ()async{
         await setTemplateData(ref, TemplateDataModel(fullName: fullName.text,email: email.text,phoneNumber: phone.text,country: country.text,street: street.text
             ,address: address.text,currentPosition: currentPosition.text,bio: bio.text))
             .whenComplete(()=>CustomPopups.showSnackBar(context,"Successfully Saved",Colors.green));;

        }, icon: Icon(Icons.check,color: Colors.white,size: 40.sp)),
      ),
    );
  }

  Widget textCard(String title,String hintText,IconData icon,TextEditingController controller,{int maxLines=1}){
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: Theme.of(context).textTheme.headlineMedium,),
          SizedBox(height: 8.h,),
          SizedBox(
            width: 1.sw,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.sp),
                  border: Border.all(color: AppColors.primaryColor),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                child: Row(
                  children: [
                    Visibility(
                        visible: maxLines==1,
                        child: Icon(icon,color: Colors.grey,size: 20.sp,)),
                    SizedBox(width: maxLines==1?8.w:0,),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        maxLines: maxLines,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: hintText,
                            hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

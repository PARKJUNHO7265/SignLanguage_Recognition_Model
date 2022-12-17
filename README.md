# Real-time sign language recognition model

<h3>About project</h3>

This is the project which we have been proceeded in Sungkyunkwan University for Graduation Project.

**Professor** : Intelligent & Biomedical electronic Engineer  유재천

**Team Members** : Electronic electrical Engineer 박준호 김효준 류지환
Mathematician 박소정
  
<h3>For what?</h3>

According to the result of the 2017 survey of the people who have deafness, 

69.3% of all respondents responded that sign language was the most used communication method.

When using facilities such as restaurants, it is impossible for deaf people to order through conversation, 

and it is hard to communicate through writing each time.

Therefore, if a sign language interpreter is installed in each store, 

deaf people will also be able to use the service conveniently.

<h3>Code</h3>

1. autolabel_0_createMask.m
2. autolabel_1_objectlabel.m
3. autolabel_2_HandDetection.m
4. function_jitterImageColorAndWarp.m
5. main_0_Get_Image.m
6. main_0_ImageSegment.m
7. main_1_Data_construct_seg.m
8. main_2_ResNet_based_YOLO.m
9. main_3_Training_seg.m
10. main_4_Evaluation.m
11. main_4_Realtime_handseg.m

<h3> How to Execute </h3>

1. main_0_Get_Image.m : Get image from webcam or camera
2. main_0_ImageSegment.m : Segment images obtained from "main_0_Get_Image"
3. Execute ImageLabeler from matlab tool
4. Click AutoLabeling button(labeling settings are coded in #1 autolabel_0_createMask 
   #2 autolabel_1_objectlabel #3 autolabel_2_HandDetection)
5. main_1_Data_construct_seg.m : Store labeled Images as data
6. main_2_ResNet_based_YOLO.m : Model to be trained
7. main_3_Training_seg.m : Training Model with data
8. main_4_Evaluation.m : Visualize train result
9. main_4_Realtime_handseg.m : Detect sign language real-time

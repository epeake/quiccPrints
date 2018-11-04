//
//  OpenCVWrapper.mm
//  quiccPrints
//
//  Created by Elijah Peake on 10/27/18.
//  Copyright © 2018 Elijah Peake. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"

using namespace cv;
using namespace std;

@interface OpenCVWrapper ()

@end

@implementation OpenCVWrapper


/*
converts our UIImage into a Mat for opencv processing
(taken from https://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html)
*/
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image {
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;

  cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels

  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                  cols,                       // Width of bitmap
                                                  rows,                       // Height of bitmap
                                                  8,                          // Bits per component
                                                  cvMat.step[0],              // Bytes per row
                                                  colorSpace,                 // Colorspace
                                                  kCGImageAlphaNoneSkipLast |
                                                  kCGBitmapByteOrderDefault); // Bitmap info flags

  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);

  return cvMat;
 }


 /*
 converts our Mat back into a UIImage
 (taken from https://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html)
 */ -(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
   NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
   CGColorSpaceRef colorSpace;

   if (cvMat.elemSize() == 1) {
       colorSpace = CGColorSpaceCreateDeviceGray();
   } else {
       colorSpace = CGColorSpaceCreateDeviceRGB();
   }

   CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

   // Creating CGImage from cv::Mat
   CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                       cvMat.rows,                                 //height
                                       8,                                          //bits per component
                                       8 * cvMat.elemSize(),                       //bits per pixel
                                       cvMat.step[0],                            //bytesPerRow
                                       colorSpace,                                 //colorspace
                                       kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                       provider,                                   //CGDataProviderRef
                                       NULL,                                       //decode
                                       false,                                      //should interpolate
                                       kCGRenderingIntentDefault                   //intent
                                       );


   // Getting UIImage from CGImage
   UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
   CGImageRelease(imageRef);
   CGDataProviderRelease(provider);
   CGColorSpaceRelease(colorSpace);

   return finalImage;
  }


// Subtracts the mask from our image (both already cropped and grayscale)
void maskDifference(Mat image, Mat mask, int valToChangeTo) {
    uchar *p, *q;
    for (int i = 0; i < image.rows; i++) {
        p = mask.ptr<uchar>(i);
        q = image.ptr<uchar>(i);
        for (int j = 0; j < image.cols; j++) {
            if (p[j] == 0) {
                q[j] = valToChangeTo;
            }
        }
    }
}


// Creates image specific mask
void makeMask(Mat image, Mat generalMask) {
    maskDifference(image, generalMask, 0);
    equalizeHist(image, image);
    cv::adaptiveThreshold(image, generalMask, 255, ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 4001, 5);
    Mat selem = cv::getStructuringElement(MORPH_ELLIPSE, Size(60, 60), Point(30, 30));
    morphologyEx(generalMask, generalMask, MORPH_OPEN, selem);
    selem = cv::getStructuringElement(MORPH_ELLIPSE, Size(50, 50), Point(25, 25));
    erode(generalMask, generalMask, selem);
}


// Extracts the fingerprint from an image using an image specific mask
void extractPrint(Mat image, Mat generalMask) {
    cv::adaptiveThreshold(image, image, 255, ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 31, 1);
    maskDifference(image, generalMask, 255);
    cv::medianBlur(image, image, 5);
}


int main(int argc, char** argv) {
    if (argc != 3) {
        cout << "Usage: picToPrint ImageToLoad MaskToSubtract" << endl;
        return -1;
    }
    
    // NEED TO FIGURE OUT THESE INPUTSSSSSSS
    Mat image = cvMatGrayFromUIImage(argv[1]);
    // read and crop files
    image = image(Range(1650,3200), Range(1000,2060));
    Mat mask = imread(argv[2], CV_LOAD_IMAGE_GRAYSCALE)(Range(1650,3200), Range(1000,2060));

    makeMask(image, mask);
    extractPrint(image, mask);
    
    return 0;
}

@end

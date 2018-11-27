#include "opencv2/opencv.hpp"

using namespace cv;
using namespace std;


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

	// read and crop files
	Mat image = imread(argv[1], CV_LOAD_IMAGE_GRAYSCALE)(Range(1650,3200), Range(1000,2060));
	Mat mask = imread(argv[2], CV_LOAD_IMAGE_GRAYSCALE)(Range(1650,3200), Range(1000,2060));

	makeMask(image, mask);
	extractPrint(image, mask);

	namedWindow( "Fingerprint", WINDOW_AUTOSIZE); // Create a window for display.
	imshow( "Fingerprint", image);                // Show our image inside it.

	waitKey(0);  // Wait for a keystroke in the window
	return 0;
}

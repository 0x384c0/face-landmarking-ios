//
//  DlibWrapper.m
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 16.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

#import "DlibWrapper.h"
#import <UIKit/UIKit.h>

#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>

@interface DlibWrapper ()

@property (assign) BOOL prepared;

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects;

@end
@implementation DlibWrapper {
    dlib::shape_predictor       shapePredictor;
    dlib::frontal_face_detector faceDetector;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}
- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    dlib::deserialize(modelFileNameCString) >> shapePredictor;
    
    faceDetector = dlib::get_frontal_face_detector();
    
    // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

- (void)doWorkOnSampleBuffer :(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects {
    ///check preparation
    if (!self.prepared) { [self prepare]; }
    
    CVImageBufferRef                imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    dlib::array2d<dlib::bgr_pixel>  img;
    /// convert the face bounds list to dlib format
    std::vector<dlib::rectangle>    convertedRectangles = [DlibWrapper convertCGRectValueArray:rects];
    
    ///get dlib image
    [self copyImageDataFromBuffer   : imageBuffer           to: &img];
    /// for every detected face draw landmarks
    [self drawFaceLanmarksOn        : convertedRectangles   to: &img];
    /// lets put everything back where it belongs
    [self copyImageDataFromImg      : &img                  to: imageBuffer];
}
- (void)drawFaceLandMarksOnImageBuffer:(CVImageBufferRef) imageBuffer{
    if (!self.prepared) { [self prepare]; }
    
    dlib::array2d<dlib::bgr_pixel>  img;
    [self copyImageDataFromBuffer   : imageBuffer           to: &img];
    
    /// find faces with dlib::frontal_face_detector
    std::vector<dlib::rectangle>    convertedRectangles = faceDetector(img);
    
    [self drawFaceLanmarksOn        : convertedRectangles   to: &img];
    [self copyImageDataFromImg      : &img                  to: imageBuffer];
}


- (void)copyImageDataFromBuffer     :(CVImageBufferRef)imageBuffer                  to:(dlib::array2d<dlib::bgr_pixel> *)dlibImage {
    
    // MARK: magic
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    /// set_size expects rows, cols format
    dlibImage->set_size(height, width);
    
    /// copy samplebuffer image data into dlib image format
    dlibImage->reset();
    long position = 0;
    while (dlibImage->move_next()) {
        dlib::bgr_pixel& pixel = dlibImage->element();
        
        /// assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        char b = baseBuffer[bufferLocation];
        char g = baseBuffer[bufferLocation + 1];
        char r = baseBuffer[bufferLocation + 2];
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        dlib::bgr_pixel newpixel(b, g, r);
        pixel = newpixel;
        
        position++;
    }
    
    /// unlock buffer again until we need it again
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
}
- (void)copyImageDataFromImg        :(dlib::array2d<dlib::bgr_pixel> *)dlibImage    to:(CVImageBufferRef)imageBuffer{
    /// lets put everything back where it belongs
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    /// copy dlib image data back into samplebuffer
    dlibImage->reset();
    long position = 0;
    while (dlibImage->move_next()) {
        dlib::bgr_pixel& pixel = dlibImage->element();
        
        /// assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        baseBuffer[bufferLocation] = pixel.blue;
        baseBuffer[bufferLocation + 1] = pixel.green;
        baseBuffer[bufferLocation + 2] = pixel.red;
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        position++;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}
- (void)drawFaceLanmarksOn          :(std::vector<dlib::rectangle>)faceRectangles   to:(dlib::array2d<dlib::bgr_pixel> *)dlibImage {
    
    /// for every detected face
    for (unsigned long j = 0; j < faceRectangles.size(); ++j)
    {
        dlib::rectangle oneFaceRect = faceRectangles[j];
        
        /// detect all landmarks
        dlib::full_object_detection shape = shapePredictor(*dlibImage, oneFaceRect);
        
        /// and draw them into the image (samplebuffer)
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            dlib::point p = shape.part(k);
            draw_solid_circle(*dlibImage, p, 3, dlib::rgb_pixel(0, 255, 255));
        }
    }
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects {
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect = [rectValue CGRectValue];
        long left = rect.origin.x;
        long top = rect.origin.y;
        long right = left + rect.size.width;
        long bottom = top + rect.size.height;
        dlib::rectangle dlibRect(left, top, right, bottom);
        
        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}
@end

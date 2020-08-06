#!/usr/bin/env python

from __future__ import print_function

import SimpleITK as sitk
import sys
import os
# import matplotlib.pyplot as plt
# import matplotlib.image as mpimg
# import numpy as np


if len ( sys.argv ) < 2:
    print( "Usage: N4BiasFieldCorrection inputImage " + \
        "outputImage [shrinkFactor] [maskImage] [numberOfIterations] " +\
        "[numberOfFittingLevels]" )
    sys.exit ( 1 )


inputImage = sitk.ReadImage( sys.argv[1] )

if len ( sys.argv ) > 4:
    maskImage = sitk.ReadImage( sys.argv[4], sitk.sitkUint8 )
else:
    maskImage = inputImage > 0
    # Whole image used as mask now (=no mask) /Christian
    # maskImage = sitk.OtsuThreshold( inputImage, 0, 1, 200 ) /Old original code
    # Otsu was not optimal due to high fat signal, creating a mask around only the fat. 
	
	
if len ( sys.argv ) > 3:
    inputImage = sitk.Shrink( inputImage, [ int(sys.argv[3]) ] * inputImage.GetDimension() )
    maskImage = sitk.Shrink( maskImage, [ int(sys.argv[3]) ] * inputImage.GetDimension() )

# Display code for image and mask
#myImage = sitk.GetArrayFromImage(inputImage)
#print(myImage.shape)
#plt.imshow(myImage[15,:,:])
#plt.show()
#plt.savefig('image.jpg')

#myMask = sitk.GetArrayFromImage(maskImage)
#print(myMask.shape)
#plt.imshow(myMask[15,:,:])
#plt.show()
#plt.savefig('test.jpg')
#sys.exit()

inputImage = sitk.Cast( inputImage, sitk.sitkFloat32 )

corrector = sitk.N4BiasFieldCorrectionImageFilter();

numberFittingLevels = 4
# This is defult value

if len ( sys.argv ) > 6:
    numberFittingLevels = int( sys.argv[6] )

if len ( sys.argv ) > 5:
    corrector.SetMaximumNumberOfIterations( [ int( sys.argv[5] ) ] *numberFittingLevels  )

output = corrector.Execute( inputImage, maskImage )

sitk.WriteImage( output, sys.argv[2] )


# if ( not "SITK_NOSHOW" in os.environ ):
#    sitk.Show( output, "N4 Corrected" )

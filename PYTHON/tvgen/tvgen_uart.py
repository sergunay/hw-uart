import numpy as np
import random
#-------------------------------------------------------------------------------
TV_FILE_NAME = "./tv.txt"
NB_TVECS = 100
#-------------------------------------------------------------------------------
TV_FILE = open(TV_FILE_NAME, "w")
#-------------------------------------------------------------------------------
class TestVector:
#-------------------------------------------------------------------------------
    def __init__(self, input_arr, nb_vecs):
        self.nb_vecs = nb_vecs
        self.vecsize = len(input_arr)
        self.testvecs = []
        for vector_idx in np.arange(nb_vecs):
            vecline = []
            for input_element in input_arr:
                element_idx = random.randrange(len(input_element))
                vecline.append(input_element[element_idx])
            self.testvecs.append(vecline)
#-------------------------------------------------------------------------------
    def print_tv(self, out_file):
        for vecline in self.testvecs:
            for element in vecline:
                out_file.write('{0:08b} '.format(element))
            out_file.write("\n")
#-------------------------------------------------------------------------------
data_set = np.arange(0, 255)
control_set = np.arange(0, 255)
input_arr = [data_set, control_set]
tv = TestVector(input_arr, NB_TVECS)
tv.print_tv(TV_FILE)
TV_FILE.close()
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

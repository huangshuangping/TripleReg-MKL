#TripleReg-MKL

This project contains *TripleReg-MKL* source code for learning Triple norm regularization MKL with application to Image classification.

This code currently implements the models proposed by Shuangping Huang

I tested this code with Ubuntu 12.04 and Windows 7.


## Getting started

1. **Get the code.** `$ git clone` the repo https://github.com/huangshuangping/TripleReg-MKL

2. **Get the data.** I don't distribute the data in the Git repo, instead download the data folder from [here](https://drive.google.com/file/d/0B8jbj0dJeIcOSGdtYWRhdFpIODA/view?usp=sharing)

3. **Run the main program.** `demo_all` 

Also, this download does not include the raw image files but include the kernel matrix.

**To be noted**:

* The code package can run to verify the experimental results on Caltech 101, 256 and Oxford Flower 102. Kernel matrix for MNIST is too big to be omitted here.
* Batch number has to be set in the config file to correctly run the program.





#include "mex.h"
#include "stdio.h"

#define SIG_BIT 64

unsigned long long get_sig(double* Z, double* T){
    unsigned long long sig = 0;
    for(int i = SIG_BIT-1; i >= 0; i--){
        sig <<= 1;
        sig += (Z[i] > T[i]);
//         printf("%d",(Z[i] > T[i]));
    }
//     printf("\n");
    return sig;
}

/*
 *  mex_get_signature(Z_array, label_array, 
 */

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 
    /* ������ */
    if (nrhs != 3) {
        mexErrMsgTxt("3 input argument required.");
    } else if (nlhs > 1) {
        mexErrMsgTxt("Too many output arguments.");
    } 
    
    const int* dim_array = mxGetDimensions(prhs[0]);                      // �൱��matlab���size
    if(dim_array[0] != SIG_BIT){                         
        mexErrMsgTxt("the length of every coloumn in 1st argumnet Z must be 64\n");           // �����ȣ�����ÿ�б�����64������64��
    }
    const int Z_count = dim_array[1];
    double* Z_array = mxGetPr(prhs[0]);
    
    dim_array = mxGetDimensions(prhs[1]);
    const int label_count = dim_array[0];
    if(label_count != Z_count){
        mexErrMsgTxt("label size must same with Z size\n");
    }
    if(!mxIsUint32(prhs[1])){
        mexErrMsgTxt("the 2rd argument labels must be uint32 array type\n");
    }
    unsigned int* label_array = (unsigned int*)mxGetPr(prhs[1]);
    
    dim_array = mxGetDimensions(prhs[2]);
    if(dim_array[0] != SIG_BIT){
        mexErrMsgTxt("the length of every coloumn in 3st argumnet T must be 64\n");           // �����ȣ�����ÿ�б�����64������64��
    }
    double* T_array = mxGetPr(prhs[2]);
    
    /* Ϊ���������������,����ı�������Ĭ���ǿյ� */
    const int dims[] = {Z_count};
    plhs[0] = mxCreateNumericArray(1, dims, mxUINT64_CLASS, mxREAL);
    unsigned long long* y = (unsigned long long*)mxGetPr(plhs[0]);
    
    for(int i = 0; i < Z_count; i++){
        y[i] = get_sig(Z_array + i * SIG_BIT, T_array + (label_array[i]-1) * SIG_BIT);          // matlab index��1��ʼ��cpp��0��ʼ�����label�����˼�1
//         printf("label: %d", label_array[i]);
//         for(int j = 0; j < SIG_BIT;j++){
//             printf("%lf, ", Z_array[j]);
//         }
//         printf("\n");
//         for(int j = 0; j < SIG_BIT;j++){
//             printf("%lf, ", *(T_array + (label_array[0]-1) * SIG_BIT +j));
//         }
//         printf("\n");
//         break;
    }  
}
#include <Rcpp.h>
using namespace Rcpp;

//' Removing the points outside the CCEP limits
//' This function ...
//'
//' @param x a numeric vector to order
//' @return A numeric vector with the order of the vector fields
// 
//
// [[Rcpp::export]]
NumericMatrix limCCEP(NumericVector x, NumericVector y, NumericMatrix z, 
                      NumericMatrix lim_min, NumericMatrix lim_max)
{
    // number of rows and columns of the matrix z
    int nr = z.nrow(), nc = z.ncol();
    
    // the returning matrix
    NumericMatrix z2( nr , nc );
    
    // aux
    int i,j,k;

    int id_min, id_max;

    // looping in cols
    for (i = 0; i < nc; i++)
    {
        // NOTE: finding the point in H min and max curves 
        // which is the first H that is >= than the current column
        
        // H
        
        // the minimum limits
        for(k = 0; k < lim_min.nrow(); k++)
        {
            if (lim_min(k,0) >= x[i])
            {
                id_min = k;
                break;
            }
        }
        
        // the maximum limits
        for(k = 0; k < lim_max.nrow(); k++)
        {
            if (lim_max(k,0) >= x[i])
            {
                id_max = k;
                break;
            }
        }
        

        // looping in rows
        for (j = 0; j < nr; j++)
        {
            // C
            //
            // checking if this point is NOT between C_min and C_max range
            // for this specific H (id_min and id_max) positions
            if (y[j] < lim_min(id_min,1)
                        ||
                lim_max(id_max,1) < y[j])
            {
                // zeroing this point significance
                z2(i,j) = 0;
            }
            else
            {
                z2(i,j) = z(i,j);
            }
        }
    }

    return z2;
}


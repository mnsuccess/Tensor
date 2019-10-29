namespace Tensor\Decompositions;

use Tensor\Matrix;
use InvalidArgumentException;
use RuntimeException;

/**
 * REF
 *
 * The row echelon form (REF) of a matrix.
 *
 * References:
 * [1] M. Rogoyski. (2019). Math PHP: Powerful modern math library for PHP.
 * http://github.com/markrogoyski/math-php.
 *
 * @category    Scientific Computing
 * @package     Rubix/Tensor
 * @author      Andrew DalPino
 */
class Ref implements Decomposition
{
    /**
     * The reduced matrix in row echelon form.
     *
     * @var \Tensor\Matrix
     */
    protected a;
    
    /**
     * The number of swaps made to compute the row echelon form of the matrix.
     *
     * @var int
     */
    protected swaps;

    /**
     * Factory method to decompose a matrix.
     *
     * @param \Tensor\Matrix a
     * @return self
     */
    public static function decompose(<Matrix> a) -> <Ref>
    {
        var e;

        try {
            return self::gaussianElimination(a);
        } catch RuntimeException, e {
            return self::rowReductionMethod(a);
        }
    }

    /**
     * Calculate the row echelon form (REF) of the matrix using Gaussian
     * elimination. Return the matrix and the number of swaps in a tuple.
     *
     * @param \Tensor\Matrix a
     * @throws \RuntimeException
     * @return self
     */
    public static function gaussianElimination(<Matrix> a) -> <Ref>
    {
        int i, j, k, index;
        var temp, diag, scale;

        var m = a->m();
        var n = a->n();

        var minDim = min(m, n);

        var b = a->asArray();

        uint swaps = 0;

        for k in range(0, minDim - 1) {
            let index = k;

            for i in range(k, m - 1) {
                if abs(b[i][k]) > abs(b[index][k]) {
                    let index = i;
                }
            }

            if unlikely b[index][k] == 0 {
                throw new RuntimeException("Cannot compute row echelon form"
                    . " of a singular matrix.");
            }

            if k !== index {
                let temp = b[k];

                let b[k] = b[index];
                let b[index] = temp;

                let swaps++;
            }

            let diag = b[k][k];

            for i in range(k + 1, m - 1) {
                let scale = diag != 0 ? b[i][k] / diag : 1;

                for j in range(k + 1, n - 1) {
                    let b[i][j] = b[i][j] - scale * b[k][j];
                }

                let b[i][k] = 0;
            }
        }

        let b = Matrix::quick(b);

        return new self(b, swaps);
    }

    /**
     * Calculate the row echelon form (REF) of the matrix using the row
     * reduction method. Return the matrix and the number of swaps in a
     * tuple.
     *
     * @param \Tensor\Matrix a
     * @return self
     */
    public static function rowReductionMethod(<Matrix> a) -> <Ref>
    {
        int i, j;
        var t, scale, divisor, temp;

        var m = a->m();
        var n = a->n();

        var b = a->asArray();

        int row = 0;
        int col = 0;

        uint swaps = 0;

        while row < m && col < n {
            let t = b[row];

            if t[col] == 0 {
                for i in range(row + 1, m - 1) {
                    if b[i][col] != 0 {
                        let temp = b[i];

                        let b[i] = t;
                        let t = temp;

                        let swaps++;

                        break;
                    }
                }
            }

            if t[col] == 0 {
                let col++;

                continue;
            }

            let divisor = t[col];

            if divisor != 1 {
                for i in range(0, n - 1) {
                    let t[i] = t[i] / divisor;
                }
            }

            for i in range(row + 1, m - 1) {
                let scale = b[i][col];

                if scale != 0 {
                    for j in range(0, n - 1) {
                        let b[i][j] = b[i][j] - scale * t[j];
                    }
                }
            }

            let b[row] = t;

            let row++;
            let col++;
        }

        let b = Matrix::quick(b);

        return new self(b, swaps);
    }

    /**
     * @param \Tensor\Matrix a
     * @param int swaps
     * @throws \InvalidArgumentException
     */
    public function __construct(<Matrix> a, int swaps)
    {
        if swaps < 0 {
            throw new InvalidArgumentException("The number of swaps must"
                . " be greater than or equal to 0, " . strval(swaps)
                . " given.");
        }

        let this->a = a;
        let this->swaps = swaps;
    }

    /**
     * Return the reduced matrix in row echelon form.
     *
     * @return \Tensor\Matrix
     */
    public function a() -> <Matrix>
    {
        return this->a;
    }

    /**
     * Return the number of swaps made to reduce the matrix to ref.
     *
     * @return int
     */
    public function swaps() -> int
    {
        return this->swaps;
    }
}

#Tau-b: Keeps the "person" together (Correlation).
#Cliff's Delta: Keeps the "groups" separate (Comparison).
function Get-CliffDelta {
    param (
        [double[]]$x,
        [double[]]$y
    )

    $sum = 0
    $nx = $x.Length
    $ny = $y.Length

    # Pairwise comparison: every element of x against every element of y
    foreach ($a in $x) {
        foreach ($b in $y) {
            if ($a -gt $b) {
                $sum += 1
            } elseif ($a -lt $b) {
                $sum -= 1
            }
            # if equal, we add 0 (do nothing)
        }
    }

    # Delta = (Concordant - Discordant) / (nx * ny)
    return $sum / ($nx * $ny)
}

function Get-Percentile {

    [CmdletBinding()]
    param (
        [Double[]]$Sequence,
        [Double]$Percentile
    )

    $Sequence = $Sequence | Sort-Object
    [int]$N = $Sequence.Length
    Write-Verbose "N is $N"
    [Double]$Num = ($N - 1) * $Percentile + 1
    Write-Verbose "Num is $Num"
    if ($num -eq 1) {
        return $Sequence[0]
    } elseif ($num -eq $N) {
        return $Sequence[$N-1]
    } else {
        $k = [Math]::Floor($Num)
        Write-Verbose "k is $k"
        [Double]$d = $num - $k
        Write-Verbose "d is $d"
        return $Sequence[$k - 1] + $d * ($Sequence[$k] - $Sequence[$k - 1])
    }
}

function bootstrap {
    param (
        [double[]]$x_orig,
        [double[]]$y_orig,
        $iterations = 1000
    )

    $nx = $x_orig.Length
    $ny = $y_orig.Length
    #   $iterations = 1000
    # -----------------#

    # FIX 1: Move this OUTSIDE the loop so it persists
    $boot_cliff = New-Object double[] $iterations

    Write-Host "Starting Bootstrap (n=$n, iterations=$iterations)..." -ForegroundColor Cyan

    for ($b = 1; $b -le $iterations; $b++) {
        $boot_x = New-Object double[] $nx
        $boot_y = New-Object double[] $ny


        # Correct way to bootstrap two groups with unequal sizes
        for ($i = 0; $i -lt $nx; $i++) {
            $idx = Get-Random -Minimum 0 -Maximum $nx
            $boot_x[$i] = $x_orig[$idx]
        }
        for ($j = 0; $j -lt $ny; $j++) {
            $ydx = Get-Random -Minimum 0 -Maximum $nx
            $boot_y[$j] = $y_orig[$ydx]
        }


        $cliff = Get-CliffDelta $boot_x $boot_y

        # Store the result
        $boot_cliff[$b-1] = $cliff

        # FIX 2: Use $($...) to display the specific array element in a string
        Write-Host "Manual $b : Cliff = $cliff " #>> Index $($b-1) stored: $($boot_tau[$b-1])"
    }

    # --- CI Calculation ---
    # Note: Percentiles are usually 0.025 and 0.975 (0 to 1 scale)
    $delta_orig = Get-CliffDelta $x_orig $y_orig
    $CI_LOWER = Get-Percentile $boot_cliff 0.025
    $CI_UPPER = Get-Percentile $boot_cliff 0.975

    Write-Host "----------------------------"
    Write-Host "Original Cliff-d: $delta_orig"
    Write-Host "Confidence interval via bootstrapping $iterations samples"
    Write-Host "CI LOWER (2.5%): $CI_LOWER"
    Write-Host "CI UPPER (97.5%): $CI_UPPER"

}

# --- Main Data ---

#$x_orig = [double[]](8.5,4,7,5.5,9,6,3.5,8,6.5,5,7.5,4.5)
#$y_orig = [double[]](5,4,7,9,9,8,3.5,8,7,9,9,8)

$csvData = Import-Csv "Book1.csv"
$x_orig = [double[]]($csvData.SLEEP)
$Y_orig = [double[]]($csvData.STRENGTH)

bootstrap $x_orig $y_orig 10

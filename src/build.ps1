function Get-AssemblyVersion($assemblyInfoPath) {
    $pattern = '\[assembly: AssemblyVersion\("(.*)"\)\]'
    (Get-Content $assemblyInfoPath) | ForEach-Object{
        if($_ -match $pattern) {
            $assemblyVersionAttribute = [version]$matches[1]
            return "{0}.{1}.{2}" -f $assemblyVersionAttribute.Major, $assemblyVersionAttribute.Minor, $assemblyVersionAttribute.Build
        }
    }
}

$nuget = ".\nuget.exe"

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$msbuild = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
if ($msbuild) {
  $msbuild = join-path $msbuild 'MSBuild\15.0\Bin\MSBuild.exe'
}

$myAppProject = "MyApp\MyApp.csproj"

& $nuget restore $myAppProject -SolutionDirectory ".\"

& $msbuild $myAppProject /p:Configuration=Release /p:AllowedReferenceRelatedFileExtensions=.pdb

# TODO change .nuspec path
# TODO change .nupkg path (or .gitignore)
# TODO change Releases path

$assemblyVersion = Get-AssemblyVersion "MyApp\Properties\AssemblyInfo.cs"

& $nuget pack MyApp.nuspec -version $assemblyVersion

# TODO if squirrel.windows version is updated
$squirrel = "packages\squirrel.windows.1.9.0\tools\Squirrel.exe"

& $squirrel --releasify "MyApp.$assemblyVersion.nupkg"

pause

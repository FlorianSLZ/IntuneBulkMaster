$Button1_Click = {
}
$Form1_Load = {
}
$PictureBox1_Click = {
}
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'start-intunebulkmaster.designer.ps1')
$Form1.ShowDialog()

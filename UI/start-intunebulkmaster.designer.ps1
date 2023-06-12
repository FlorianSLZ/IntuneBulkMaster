$Form1 = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$Button2 = $null
[System.Windows.Forms.Button]$Button3 = $null
[System.Windows.Forms.Button]$Button4 = $null
[System.Windows.Forms.RichTextBox]$RichTextBox1 = $null
[System.Windows.Forms.Button]$Button5 = $null
[System.Windows.Forms.Button]$Button1 = $null
[System.Windows.Forms.Button]$Button6 = $null
[System.Windows.Forms.Button]$Button7 = $null
[System.Windows.Forms.Button]$Button8 = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'start-intunebulkmaster.resources.ps1')
$Button2 = (New-Object -TypeName System.Windows.Forms.Button)
$Button3 = (New-Object -TypeName System.Windows.Forms.Button)
$Button4 = (New-Object -TypeName System.Windows.Forms.Button)
$RichTextBox1 = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$Button5 = (New-Object -TypeName System.Windows.Forms.Button)
$Button1 = (New-Object -TypeName System.Windows.Forms.Button)
$Button6 = (New-Object -TypeName System.Windows.Forms.Button)
$Button7 = (New-Object -TypeName System.Windows.Forms.Button)
$Button8 = (New-Object -TypeName System.Windows.Forms.Button)
$Form1.SuspendLayout()
#
#Button2
#
$Button2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1,[System.Int32]2))
$Button2.Name = [System.String]'Button2'
$Button2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]23))
$Button2.TabIndex = [System.Int32]1
$Button2.Text = [System.String]'All'
$Button2.UseVisualStyleBackColor = $true
#
#Button3
#
$Button3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]72,[System.Int32]2))
$Button3.Name = [System.String]'Button3'
$Button3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]23))
$Button3.TabIndex = [System.Int32]2
$Button3.Text = [System.String]'Group'
$Button3.UseVisualStyleBackColor = $true
#
#RichTextBox1
#
$RichTextBox1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]31))
$RichTextBox1.Name = [System.String]'RichTextBox1'
$RichTextBox1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]760,[System.Int32]64))
$RichTextBox1.TabIndex = [System.Int32]4
$RichTextBox1.Text = [System.String]''
#
#Button1
#
$Button1.BackColor = [System.Drawing.SystemColors]::ButtonHighlight
$Button1.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$Button1.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]8.25))
$Button1.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Button1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]153,[System.Int32]113))
$Button1.Name = [System.String]'Button1'
$Button1.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Button1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]103,[System.Int32]104))
$Button1.TabIndex = [System.Int32]0
$Button1.Text = [System.String]'Sync'
$Button1.UseVisualStyleBackColor = $true
#
#Button6
#
$Button6.BackColor = [System.Drawing.SystemColors]::ButtonHighlight
$Button6.BackgroundImage = ([System.Drawing.Image]$resources.'Button6.BackgroundImage')
$Button6.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$Button6.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]8.25))
$Button6.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Button6.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]283,[System.Int32]113))
$Button6.Name = [System.String]'Button6'
$Button6.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Button6.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]103,[System.Int32]104))
$Button6.TabIndex = [System.Int32]0
$Button6.Text = [System.String]'Sync'
$Button6.UseVisualStyleBackColor = $true
#
#Button8
#
$Button8.BackColor = [System.Drawing.SystemColors]::ButtonHighlight
$Button8.BackgroundImage = ([System.Drawing.Image]$resources.'Button8.BackgroundImage')
$Button8.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$Button8.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Tahoma',[System.Single]8.25))
$Button8.ForeColor = [System.Drawing.Color]::FromArgb(([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)),([System.Int32]([System.Byte][System.Byte]0)))

$Button8.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]544,[System.Int32]113))
$Button8.Name = [System.String]'Button8'
$Button8.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$Button8.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]103,[System.Int32]104))
$Button8.TabIndex = [System.Int32]0
$Button8.Text = [System.String]'Sync'
$Button8.UseVisualStyleBackColor = $true
#
#Form1
#
$Form1.BackColor = [System.Drawing.SystemColors]::ButtonHighlight
$Form1.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]784,[System.Int32]261))
$Form1.Controls.Add($RichTextBox1)
$Form1.Controls.Add($Button4)
$Form1.Controls.Add($Button3)
$Form1.Controls.Add($Button2)
$Form1.Controls.Add($Button5)
$Form1.Controls.Add($Button1)
$Form1.Controls.Add($Button6)
$Form1.Controls.Add($Button7)
$Form1.Controls.Add($Button8)
$Form1.Icon = ([System.Drawing.Icon]$resources.'$this.Icon')
$Form1.Text = [System.String]'IntuneBulkMaster'
$Form1.add_Load($Form1_Load)
$Form1.ResumeLayout($false)
Add-Member -InputObject $Form1 -Name Button2 -Value $Button2 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button3 -Value $Button3 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button4 -Value $Button4 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name RichTextBox1 -Value $RichTextBox1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button5 -Value $Button5 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button1 -Value $Button1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button6 -Value $Button6 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button7 -Value $Button7 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button8 -Value $Button8 -MemberType NoteProperty
}
. InitializeComponent

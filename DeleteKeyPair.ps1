param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$KEYPAIR
)    
aws ec2 delete-key-pair --key-name $KEYPAIR

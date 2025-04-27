resource "aws_ssm_document" "this" {
  count         = var.domain_id != "" ? 1 : 0
  name          = "${var.name}-ad-join-domain"
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "aws:domainJoin"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId" : data.aws_directory_service_directory.this[0].id,
            "directoryName" : data.aws_directory_service_directory.this[0].name
            "dnsIpAddresses" : sort(data.aws_directory_service_directory.this[0].dns_ip_addresses)
          }
        }
      ]
    }
  )
}

resource "aws_ssm_association" "this" {
  count = var.domain_id != "" ? 1 : 0
  name  = aws_ssm_document.this[0].name
  targets {
    key    = "InstanceIds"
    values = aws_instance.this[*].id
  }
}

resource "aws_iam_role_policy_attachment" "this_ssm_instance" {
  count      = var.domain_id != "" && var.iam_role == "" ? 1 : 0
  role       = aws_iam_role.this[0].id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "this_ssm_ad" {
  count      = var.domain_id != "" && var.iam_role == "" ? 1 : 0
  role       = aws_iam_role.this[0].id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}
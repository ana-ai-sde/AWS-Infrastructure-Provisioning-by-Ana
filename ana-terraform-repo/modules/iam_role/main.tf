resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = var.assume_role_policy

  tags = merge(
    {
      Name = var.role_name
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arns[count.index]
}

resource "aws_iam_role_policy" "inline_policy" {
  count  = var.inline_policy != null ? 1 : 0
  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.this.id
  policy = var.inline_policy
}
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric checks cpu utilization"
  alarm_actions       = [aws_sns_topic.cpu_alarm.arn]
  dimensions = {
    InstanceId = aws_instance.dev_node.id
  }
}

resource "aws_sns_topic" "cpu_alarm" {
  name = "cpu-utilization-alarm"
}

# OUTPUT Shows connection to ec2 instance
output "aws_instance_public_dns" {
  value = aws_instance.dev_node.public_dns
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_name          = "terramino_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.terrascale.name
  }
}


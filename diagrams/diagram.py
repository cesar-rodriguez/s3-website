# diagram.py
from diagrams import Cluster, Diagram
from diagrams.aws.general import Users
from diagrams.aws.storage import S3
from diagrams.aws.network import CF, ELB
from diagrams.aws.compute import EC2

with Diagram("Terrascan Website", show=False, filename="01-s3-public-bucket"):
    users = Users("users")
    with Cluster("Internet Exposed"):
        s3 = S3("static-assets")

    users >> s3

with Diagram("Terrascan Website", show=False, filename="02-s3-block-public-access"):
    users = Users("users")
    with Cluster("Private Only"):
        s3 = S3("static-assets")

with Diagram("Terrascan Website", show=False, filename="03-s3-behind-cloudfront"):
    users = Users("users")
    with Cluster("Internet Exposed"):
        cf = CF("CDN")
    with Cluster("Private Only"):
        s3 = S3("static-assets")

    users >> cf >> s3

with Diagram("Terrascan Website", show=False, filename="04-public-elb-behind-cloudfront"):
    users = Users("users")
    with Cluster("Internet Exposed"):
        cf = CF("CDN")
        elb = ELB("Load Balancer")
    with Cluster("Private Only"):
        s3 = S3("static-assets")
        ec2 = EC2("app-server")

    users >> cf >> s3
    cf >> elb >> ec2

with Diagram("Terrascan Website", show=False, filename="05-lockdown-elb-behind-cloudfront"):
    users = Users("users")
    with Cluster("Internet Exposed"):
        cf = CF("CDN")
    with Cluster("CloudFront Only"):
        elb = ELB("Load Balancer")
    with Cluster("Private Only"):
        s3 = S3("static-assets")
        ec2 = EC2("app-server")

    users >> cf >> s3
    cf >> elb >> ec2

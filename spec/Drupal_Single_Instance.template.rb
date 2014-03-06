AWSTemplateFormatVersion "2010-09-09"

Description (<<-EOS).undent
  AWS CloudFormation Sample Template Drupal_Single_Instance.
   Drupal is an open source content management platform powering millions of websites and applications.
   This template installs a singe instance deployment with a local MySQL database for storage.
   It uses the AWS CloudFormation bootstrap scripts to install packages and files at instance launch time.

   **WARNING**
   This template creates an Amazon EC2 instance.
   You will be billed for the AWS resources used if you create a stack from this template.
EOS

Parameters do
  KeyName do
    Description "Name of an existing EC2 KeyPair to enable SSH access to the instances"
    Type "String"
    MinLength 1
    MaxLength 255
    AllowedPattern "[\\x20-\\x7E]*"
    ConstraintDescription "can contain only ASCII characters."
  end
  InstanceType do
    Description "WebServer EC2 instance type"
    Type "String"
    Default "m1.small"
    AllowedValues "t1.micro", "m1.small", "m1.medium", "m1.large", "m1.xlarge", "m2.xlarge", "m2.2xlarge", "m2.4xlarge", "m3.xlarge", "m3.2xlarge", "c1.medium", "c1.xlarge", "cc1.4xlarge", "cc2.8xlarge", "cg1.4xlarge"
    ConstraintDescription "must be a valid EC2 instance type."
  end
  SiteName do
    Default "My Site"
    Description "The name of the Drupal Site"
    Type "String"
  end
  SiteEMail do
    Description "EMail for site adminitrator"
    Type "String"
  end
  SiteAdmin do
    Description "The Drupal site admin account username"
    Type "String"
    MinLength 1
    MaxLength 16
    AllowedPattern "[a-zA-Z][a-zA-Z0-9]*"
    ConstraintDescription "must begin with a letter and contain only alphanumeric characters."
  end
  SitePassword do
    NoEcho "true"
    Description "The Drupal site admin account password"
    Type "String"
    MinLength 1
    MaxLength 41
    AllowedPattern "[a-zA-Z0-9]*"
    ConstraintDescription "must contain only alphanumeric characters."
  end
  DBName do
    Default "drupaldb"
    Description "The Drupal database name"
    Type "String"
    MinLength 1
    MaxLength 64
    AllowedPattern "[a-zA-Z][a-zA-Z0-9]*"
    ConstraintDescription "must begin with a letter and contain only alphanumeric characters."
  end
  DBUsername do
    Default "admin"
    NoEcho "true"
    Description "The Drupal database admin account username"
    Type "String"
    MinLength 1
    MaxLength 16
    AllowedPattern "[a-zA-Z][a-zA-Z0-9]*"
    ConstraintDescription "must begin with a letter and contain only alphanumeric characters."
  end
  DBPassword do
    Default "admin"
    NoEcho "true"
    Description "The Drupal database admin account password"
    Type "String"
    MinLength 1
    MaxLength 41
    AllowedPattern "[a-zA-Z0-9]*"
    ConstraintDescription "must contain only alphanumeric characters."
  end
  DBRootPassword do
    NoEcho "true"
    Description "Root password for MySQL"
    Type "String"
    MinLength 1
    MaxLength 41
    AllowedPattern "[a-zA-Z0-9]*"
    ConstraintDescription "must contain only alphanumeric characters."
  end
  SSHLocation do
    Description "The IP address range that can be used to SSH to the EC2 instances"
    Type "String"
    MinLength 9
    MaxLength 18
    Default "0.0.0.0/0"
    AllowedPattern "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})"
    ConstraintDescription "must be a valid IP CIDR range of the form x.x.x.x/x."
  end
end

Mappings do
  AWSInstanceType2Arch(
    {"t1.micro"=>{"Arch"=>"64"},
     "m1.small"=>{"Arch"=>"64"},
     "m1.medium"=>{"Arch"=>"64"},
     "m1.large"=>{"Arch"=>"64"},
     "m1.xlarge"=>{"Arch"=>"64"},
     "m2.xlarge"=>{"Arch"=>"64"},
     "m2.2xlarge"=>{"Arch"=>"64"},
     "m2.4xlarge"=>{"Arch"=>"64"},
     "m3.xlarge"=>{"Arch"=>"64"},
     "m3.2xlarge"=>{"Arch"=>"64"},
     "c1.medium"=>{"Arch"=>"64"},
     "c1.xlarge"=>{"Arch"=>"64"},
     "cc1.4xlarge"=>{"Arch"=>"64HVM"},
     "cc2.8xlarge"=>{"Arch"=>"64HVM"},
     "cg1.4xlarge"=>{"Arch"=>"64HVM"}})
  AWSRegionArch2AMI(
    {"us-east-1"=>
      {"32"=>"ami-a0cd60c9", "64"=>"ami-aecd60c7", "64HVM"=>"ami-a8cd60c1"},
     "us-west-2"=>
      {"32"=>"ami-46da5576", "64"=>"ami-48da5578", "64HVM"=>"NOT_YET_SUPPORTED"},
     "us-west-1"=>
      {"32"=>"ami-7d4c6938", "64"=>"ami-734c6936", "64HVM"=>"NOT_YET_SUPPORTED"},
     "eu-west-1"=>
      {"32"=>"ami-61555115", "64"=>"ami-6d555119", "64HVM"=>"ami-67555113"},
     "ap-southeast-1"=>
      {"32"=>"ami-220b4a70", "64"=>"ami-3c0b4a6e", "64HVM"=>"NOT_YET_SUPPORTED"},
     "ap-southeast-2"=>
      {"32"=>"ami-b3990e89", "64"=>"ami-bd990e87", "64HVM"=>"NOT_YET_SUPPORTED"},
     "ap-northeast-1"=>
      {"32"=>"ami-2a19aa2b", "64"=>"ami-2819aa29", "64HVM"=>"NOT_YET_SUPPORTED"},
     "sa-east-1"=>
      {"32"=>"ami-f836e8e5", "64"=>"ami-fe36e8e3", "64HVM"=>"NOT_YET_SUPPORTED"}})
end

Resources do
  WebServer do
    Type "AWS::EC2::Instance"
    Metadata do
      AWS__CloudFormation__Init do
        config do
          packages do
            yum(
              {"httpd"=>[],
               "php"=>[],
               "php-mysql"=>[],
               "php-gd"=>[],
               "php-xml"=>[],
               "php-mbstring"=>[],
               "mysql"=>[],
               "mysql-server"=>[],
               "mysql-devel"=>[],
               "mysql-libs"=>[]})
          end
          sources do
            _path "/var/www/html", "http://ftp.drupal.org/files/projects/drupal-7.8.tar.gz"
            _path "/home/ec2-user", "http://ftp.drupal.org/files/projects/drush-7.x-4.5.tar.gz"
          end
          files do
            _path("/tmp/setup.mysql") do
              content (<<-EOS).fn_join
                CREATE DATABASE <%= Ref "DBName" %>;
                CREATE USER '<%= Ref "DBUsername" %>'@'localhost' IDENTIFIED BY '<%= Ref "DBPassword" %>';
                GRANT ALL ON <%= Ref "DBName" %>.* TO '<%= Ref "DBUsername" %>'@'localhost';
                FLUSH PRIVILEGES;
              EOS
              mode "000644"
              owner "root"
              group "root"
            end
          end
          services do
            sysvinit do
              httpd do
                enabled "true"
                ensureRunning "true"
              end
              mysqld do
                enabled "true"
                ensureRunning "true"
              end
              sendmail do
                enabled "false"
                ensureRunning "false"
              end
            end
          end
        end
      end
    end

    Properties do
      ImageId do
        Fn__FindInMap "AWSRegionArch2AMI", _{ Ref "AWS::Region" }, _{
          Fn__FindInMap "AWSInstanceType2Arch", _{ Ref "InstanceType" }, "Arch"
        }
      end
      InstanceType do
        Ref "InstanceType"
      end
      SecurityGroups [
        _{ Ref "WebServerSecurityGroup" }
      ]
      KeyName do
        Ref "KeyName"
      end
      UserData do
        Fn__Base64 (<<-EOS).fn_join
          #!/bin/bash -v
          yum update -y aws-cfn-bootstrap
          # Helper function
          function error_exit
          {
            /opt/aws/bin/cfn-signal -e 0 -r "$1" '<%= Ref "WaitHandle" %>'
            exit 1
          }
          # Install Apache Web Server, MySQL, PHP and Drupal
          /opt/aws/bin/cfn-init -s <%= Ref "AWS::StackId" %> -r WebServer --region <%= Ref "AWS::Region" %> || error_exit 'Failed to run cfn-init'
          # Setup MySQL root password and create a user
          mysqladmin -u root password '<%= Ref "DBRootPassword" %>' || error_exit 'Failed to initialize root password'
          mysql -u root --password='<%= Ref "DBRootPassword" %>' < /tmp/setup.mysql || error_exit 'Failed to create database user'
          # Make changes to Apache Web Server configuration
          mv /var/www/html/drupal-7.8/* /var/www/html
          mv /var/www/html/drupal-7.8/.* /var/www/html
          rmdir /var/www/html/drupal-7.8
          sed -i 's/AllowOverride None/AllowOverride All/g'  /etc/httpd/conf/httpd.conf
          service httpd restart
          # Create the site in Drupal
          cd /var/www/html
          ~ec2-user/drush/drush site-install standard --yes --site-name='<%= Ref "SiteName" %>' --site-mail=<%= Ref "SiteEMail" %> --account-name=<%= Ref "SiteAdmin" %> --account-pass=<%= Ref "SitePassword" %> --db-url=mysql://<%= Ref "DBUsername" %>:<%= Ref "DBPassword" %>@localhost/<%= Ref "DBName" %> --db-prefix=drupal_
          chown apache:apache sites/default/files
          # All is well so signal success
          /opt/aws/bin/cfn-signal -e 0 -r "Drupal setup complete" '<%= Ref "WaitHandle" %>'
        EOS
      end
    end
  end
  WaitHandle do
    Type "AWS::CloudFormation::WaitConditionHandle"
  end
  WaitCondition do
    Type "AWS::CloudFormation::WaitCondition"
    DependsOn "WebServer"
    Properties do
      Handle do
        Ref "WaitHandle"
      end
      Timeout 300
    end
  end
  WebServerSecurityGroup do
    Type "AWS::EC2::SecurityGroup"
    Properties do
      GroupDescription "Enable HTTP access via port 80 and SSH access"
      SecurityGroupIngress [
        _{
          IpProtocol "tcp"
          FromPort 80
          ToPort 80
          CidrIp "0.0.0.0/0"
        },
        _{
          IpProtocol "tcp"
          FromPort 22
          ToPort 22
          CidrIp do
            Ref "SSHLocation"
          end
        }
      ]
    end
  end
end
Outputs do
  WebsiteURL do
    Value 'http://<%= Fn__GetAtt "WebServer", "PublicDnsName" %>'.fn_join
    Description "Drupal Website"
  end
end

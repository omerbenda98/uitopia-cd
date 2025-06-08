resource "local_file" "inventory" {
  filename = "../ansible/inventory.ini"

  content = join("\n", concat(
    ["[app]"],
    [for i in range(length(module.app.ec2_private_ips)) :
      "${module.app.ec2_names[i]} ansible_host=${module.app.ec2_private_ips[i]} ansible_user=ubuntu"
    ],
    ["[stage]"],
    [for i in range(length(module.stage.ec2_private_ips)) :
      "${module.stage.ec2_names[i]} ansible_host=${module.stage.ec2_private_ips[i]} ansible_user=ubuntu"
    ]
  ))
}
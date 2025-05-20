terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.50, != 4.31.0, != 6.26.0, != 6.27.0, < 7.0"
    }
  }
}

locals {
  access_policy_id = "accessPolicies/123123123123"
}

resource "google_access_context_manager_service_perimeter" "example_perimeter" {
  name           = "${local.access_policy_id}/servicePerimeters/examplePerimeter"
  parent         = local.access_policy_id
  title          = "Example Perimeter"
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  status {
    resources = [
      "projects/333333333333" //service-perimeter-project
    ]

    # Ingress Rule 1: Allow projects
    ingress_policies {
      ingress_from {
        sources {
          resource =  "projects/111111111111" //out-perimeter-project1
        }
        sources {
          resource = "projects/222222222222"//out-perimeter-project2
        }
      }

      ingress_to {
        operations {
          service_name = "bigquery.googleapis.com"
          method_selectors {
            method =  "*"
          }
        }
      }
    }

    # Ingress Rule 2: Allow access access level
    ingress_policies {
      ingress_from {
        sources {
          access_level = "*"
        }
      }

      ingress_to {
        operations {
          service_name = "storage.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
      }
    }

    # Egress Rule: Allow traffic to projects
    egress_policies {
      egress_from {}
      egress_to {
        resources = [
          "projects/111111111111", //out-perimeter-project1
          "projects/222222222222" //out-perimeter-project2
        ]
      }
    }
  }
}

resource "google_access_context_manager_access_policy_iam_member" "user_admin" {
  name   = local.access_policy_id
  role   = "roles/accesscontextmanager.policyAdmin"
  member = "user:user@domain.com"
}

//////////////////////////////////////////////////////////////

# module "regular_service_perimeter" {
#   source         = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
#   version        = "~> 6.2.1"

#   policy         = "123123123123123"
#   perimeter_name = "regular_perimeter_1"
#   description    = "Test Perimeter 1"
#   resources      = ["448343322927"]

#   restricted_services = ["bigquery.googleapis.com", "aiplatform.googleapis.com"]

#   ingress_policies = [
#     // ingress 1
#     {
#     from = {
#       sources = {
#         resources = ["projects/349198887463"]
#       }
#       # identity_type = ""
#       # identities    = ["user:username@domain.com"]
#     }
#     to = {
#       operations = {
#         "*" = {
#           methods = ["*"]
#         }
#       }
#     }
#   },
#   //ingress2
#   {
#     from = {
#       # identity_type = ""
#       # identities    = ["user:username@domain.com"]
#       //identity_type = "ANY_IDENTITY"
#       sources = {
#         resources = [
#           "projects/349198887463",
#           "projects/317298441760"
#         ]
#       }
#     }
#     to = {
#       operations = {
#         "*" = {
#           methods = ["*"]
#         }
#       }
#     }
#   }
#   ]

#   egress_policies = [{
#     from = {
#       identity_type = ""
#       identities    = ["user:username@domain.com"]
#     }
#     to = {
#       resources = ["*"]
#       operations = {
#         "*" = {
#           methods = ["*"]
#         }
#       }
#     }
#   }]

#   shared_resources = {
#     all = ["448343322927"]
#   }
# }


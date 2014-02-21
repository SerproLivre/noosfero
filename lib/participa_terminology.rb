require 'noosfero/terminology'

class ParticipaTerminology < Noosfero::Terminology::Custom

  def initialize
    # NOTE: the hash values must be marked for translation!!
    super({
      'Enterprises' => N_('Organizations'),
      'enterprises' => N_('organizations'),
      'The enterprises where this user works.' => N_('The organization where this user belongs.'),
      'A block that displays your enterprises' => N_('A block that displays your organizations.'),
      'All enterprises' => N_('All organizations'),
      'Disable search for enterprises' => N_('Disable search for organizations'),
      'One enterprise' => N_('One organization'),
      '%{num} enterprises' => N_('%{num} organizations'),
      'Favorite Enterprises' => N_('Favorite Organizations'),
      'This user\'s favorite enterprises.' => N_('This user\'s favorite organizations'),
      'A block that displays your favorite enterprises' => N_('A block that displays your favorite organizations'),
      'All favorite enterprises' => N_('All favorite organizations'),
      'A search for enterprises by products selled and local' => N_('A search for organizations by products selled and local'),
      'Edit message for disabled enterprises' => N_('Edit message for disabled organizations'),
      'Add favorite enterprise' => N_('Add favorite organization'),
      'Validation info is the information the enterprises will see about how your organization processes the enterprises validations it receives: validation methodology, restrictions to the types of enterprises the organization validates etc.' => N_('Validation info is the information the organizations will see about how your organization processes the organization validations it receives: validation methodology, restrictions to the types of institutions the organization validates etc.'),
      'Here are all <b>%s</b>\'s enterprises.' => N_('Here are all <b>%s</b>\'s organizations.'),
      'Here are all <b>%s</b>\'s favorite enterprises.' => N_('Here are all <b>%s</b>\'s favorite organizations.'),
      'Favorite Enterprises' => N_('Favorite Organizations'),
      'Enterprises in "%s"' => N_('Organizations in "%s"'),
      'Register a new Enterprise' => N_('Register a new Organization'),
      'Events' => N_('Schedule'),
      'Manage enterprise fields' => N_('Manage organizations fields'),
      "%s's enterprises" => N_("%s's organizations"),
      'Activate your enterprise' => N_('Activate your organization'),
      'Enterprise activation code' => N_('Organization activation code'),
      'Enable activation of enterprises' => N_('Enable activation of organizations'),
      "%s's favorite enterprises" => N_("%s's favorite organizations"),
      'Disable Enterprise' => N_('Disable Organization'),
      'Enable Enterprise' => N_('Enable Organization'),
      'Enterprise Validation' => N_('Organization Validation'),
      'Enterprise Info and settings' => N_('Organization Info and settings'),
      'Enterprises are disabled when created' => N_('Organizations are disabled when created'),
      'Display on menu the list of enterprises the user can manage' => N_('Display on menu the list of organizations the user can manage'),
      'Enable products for enterprises' => N_('Enable products for organizations'),
      'Enterprise registration' => N_('Organization registration'),
      'Enterprises are validated when created' => N_('Organizations are validated when created'),
      'Enterprise-related settings' => N_('Organization-related settings'),
      'Message for disabled enterprises' => N_('Message for disabled organizations'),
    })
  end
end

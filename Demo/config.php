<?php
/**
 * i-MSCP - internet Multi Server Control Panel
 * Copyright (C) 2010 - 2013 by i-MSCP Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * @category    iMSCP
 * @package     iMSCP_Plugins
 * @subpackage  Demo
 * @copyright   2010 - 2013 by i-MSCP Team
 * @author      Laurent Declercq <l.declercq@nuxwin.com>
 * @link        http://www.i-mscp.net i-MSCP Home Site
 * @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2
 */

// Configuration file sample for the demo plugin

return array(
	//	List of user accounts that will be available via select box on login page. If an user account is protected, it
	//	will be imposible to remove it. Also, its password will be protected against modification.
	'user_accounts' => array(
		array(
			'label' => 'Administrator 1',
			'username' => 'admin1',
			'password' => 'admin1',
			'protected' => true
		),
		array(
			'label' => 'Administrator 2',
			'username' => 'admin2',
			'password' => 'admin2',
			'protected' => true
		),
		array(
			'label' => 'Administrator 3',
			'username' => 'admin3',
			'password' => 'admin3',
			'protected' => true
		),
		array(
			'label' => 'Reseller 1',
			'username' => 'reseller1',
			'password' => 'reseller1',
			'protected' => true
		),
		array(
			'label' => 'Reseller 2',
			'username' => 'reseller2',
			'password' => 'reseller2',
			'protected' => true
		),
		array(
			'label' => 'Reseller 3',
			'username' => 'reseller3',
			'password' => 'reseller3',
			'protected' => true
		),
		array(
			'label' => 'Customer 1',
			'username' => 'domain1.tld',
			'password' => 'domain1',
			'protected' => true
		),
		array(
			'label' => 'Customer 2',
			'username' => 'domain2.tld',
			'password' => 'domain2',
			'protected' => true
		),
		array(
			'label' => 'Customer 3',
			'username' => 'domain3.tld',
			'password' => 'domain3',
			'protected' => true
		)
	),

	// List of actions that must be totally disabled. Each action must be prefixed by 'onBefore'
	//
	// Important consideration:
	// Even if you add the 'onBeforeDeactivatePlugin' in the list below, you'll still able to deactivate this plugin.
	// The only way to protect this plugin against deactivation is to protect it using the plugin protection feature.
	'disabled_actions' => array(
		'onBeforeEditAdminGeneralSettings',
		'onBeforeAddUser',
		'onBeforeEditUser',
		'onBeforeDeleteUser',
		'onBeforeDeleteCustomer',
		'onBeforeAddFtp',
		'onBeforeEditFtp',
		'onBeforeDeleteFtp',
		'onBeforeAddSqlUser',
		'onBeforeEditSqlUser',
		'onBeforeDeleteSqlUser',
		'onBeforeAddSqlDb',
		'onBeforeDeleteSqlDb',
		'onBeforeUpdatePluginList',
		'onBeforeActivatePlugin',
		'onBeforeDeactivatePlugin',
		'onBeforeUpdatePlugin',
		'onBeforeDeletePlugin',
		'onBeforeProtectPlugin',
		'onBeforeAddDomain',
		'onBeforeEditDomain',
		'onBeforeAddSubdomain',
		'onBeforeEditSubdomain',
		'onBeforeDeleteSubdomain',
		'onBeforeAddDomainAlias',
		'onBeforeEditDomainAlias',
		'onBeforeDeleteDomainAlias',
		'onBeforeAddMail',
		'onBeforeEditMail',
		'onBeforeDeleteMail',
		'onBeforeAddExternalMailServer',
		'onBeforeChangeDomainStatus'
	)
);

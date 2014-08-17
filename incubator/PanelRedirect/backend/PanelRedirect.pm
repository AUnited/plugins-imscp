#!/usr/bin/perl

=head1 NAME

 Plugin::PanelRedirect

=cut

# i-MSCP PanelRedirect plugin
# Copyright (C) 2014 by Ninos Ego <me@ninosego.de>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

package Plugin::PanelRedirect;

use strict;
use warnings;

no if $] >= 5.017011, warnings => 'experimental::smartmatch';

use iMSCP::Debug;
use iMSCP::Dir;
use iMSCP::File;
use iMSCP::Database;
use iMSCP::Net;
use Servers::httpd;
use JSON;

use parent 'Common::SingletonClass';

=head1 DESCRIPTION

 This package provides the backend part for the i-MSCP PanelRedirect plugin

=head1 PUBLIC METHODS

=over 4

=item install()

 Process install tasks

 Return int 0 on success, other on failure

=cut

sub install
{
	$_[0]->_createLogFolder();
}

=item uninstall()

 Process uninstall tasks

 Return int 0 on success, other on failure

=cut

sub uninstall
{
	$_[0]->_removeLogFolder();
}

=item enable()

 Process enable tasks

 Return int 0 on success, other on failure

=cut

sub enable
{
	my $self = $_[0];

	my $rs = $self->_createConfig('00_PanelRedirect.conf');
	return $rs if $rs;

	if($main::imscpConfig{'PANEL_SSL_ENABLED'} eq 'yes') {
		$rs = $self->_createConfig('00_PanelRedirect_ssl.conf');
		return $rs if $rs;
	} else {
		$rs = $self->_removeConfig('00_PanelRedirect_ssl.conf');
		return $rs if $rs;
	}

	$self->{'httpd'}->{'restart'} = 'yes';

	0;
}

=item disable()

 Process disable tasks

 Return int 0 on success, other on failure

=cut

sub disable
{
	my $self = $_[0];

	for('00_PanelRedirect.conf', '00_PanelRedirect_ssl.conf') {
		my $rs = $self->_removeConfig($_);
		return $rs if $rs;
	}

	$self->{'httpd'}->{'restart'} = 'yes';

	0;
}

=back

=head1 PRIVATE METHODS

=over 4

=item _init()

 Initialize plugin

 Return Plugin::PanelRedirect

=cut

sub _init
{
	my $self = $_[0];

	$self->{'httpd'} = Servers::httpd->factory();

	if($self->{'action'} ~~ ['install', 'change', 'update', 'enable', 'disable']) {
		my $rdata = iMSCP::Database->factory()->doQuery(
			'plugin_name', 'SELECT plugin_name, plugin_config FROM plugin WHERE plugin_name = ?', 'PanelRedirect'
		);
		unless(ref $rdata eq 'HASH') {
			fatal($rdata);
		}

		$self->{'config'} = decode_json($rdata->{'PanelRedirect'}->{'plugin_config'});
	}

	$self;
}

=item _createConfig($vhostTplFile)

 Create httpd configs

 Param string $vhostTplFile Vhost template file
 Return int 0 on success, other on failure

=cut

sub _createConfig
{
	my ($self, $vhostTplFile) = @_;

	my $tplRootDir = "$main::imscpConfig{'GUI_ROOT_DIR'}/plugins/PanelRedirect/templates/$self->{'config'}->{'type'}";

	my $ipMngr = iMSCP::Net->getInstance();

	$self->{'httpd'}->setData(
		{
			'BASE_SERVER_IP' => ($ipMngr->getAddrVersion($main::imscpConfig{'BASE_SERVER_IP'}) eq 'ipv4')
				? $main::imscpConfig{'BASE_SERVER_IP'} : "[$main::imscpConfig{'BASE_SERVER_IP'}]",
			'BASE_SERVER_VHOST' => $main::imscpConfig{'BASE_SERVER_VHOST'},
			'BASE_SERVER_VHOST_PREFIX' => $main::imscpConfig{'BASE_SERVER_VHOST_PREFIX'},
			'BASE_SERVER_VHOST_PORT' => ($main::imscpConfig{'BASE_SERVER_VHOST_PREFIX'} eq 'http://')
				? $main::imscpConfig{'BASE_SERVER_VHOST_HTTP_PORT'} : $main::imscpConfig{'BASE_SERVER_VHOST_HTTPS_PORT'},
			'DEFAULT_ADMIN_ADDRESS' => $main::imscpConfig{'DEFAULT_ADMIN_ADDRESS'},
			'HTTPD_LOG_DIR' => $self->{'httpd'}->{'config'}->{'HTTPD_LOG_DIR'},
			'CONF_DIR' => $main::imscpConfig{'CONF_DIR'}
		}
	);

	my $rs = $self->{'httpd'}->buildConfFile("$tplRootDir/$vhostTplFile");
	return $rs if $rs;

	$rs = $self->{'httpd'}->installConfFile($vhostTplFile);
	return $rs if $rs;

	$self->{'httpd'}->enableSites($vhostTplFile);
}

=item _removeConfig($vhostFile)

 Remove httpd configs

 Param string $vhostFile Vhost file
 Return int 0 on success, other on failure

=cut

sub _removeConfig
{
	my ($self, $vhostFile) = @_;

	my $rs = $self->{'httpd'}->disableSites($vhostFile);
	return $rs if $rs;

	for(
		"$self->{'httpd'}->{'apacheWrkDir'}/$vhostFile",
		"$self->{'httpd'}->{'config'}->{'HTTPD_SITES_AVAILABLE_DIR'}/$vhostFile"
	) {
		if(-f $_) {
			$rs = iMSCP::File->new('filename' => $_)->delFile();
			return $rs if $rs;
		}
	}

	0;
}

=item _createLogFolder()

 Create httpd log folder

 Return int 0 on success, other on failure

=cut

sub _createLogFolder()
{
	iMSCP::Dir->new(
		'dirname' => "$_[0]->{'httpd'}->{'config'}->{'HTTPD_LOG_DIR'}/$main::imscpConfig{'BASE_SERVER_VHOST'}"
	)->make(
		{ 'user' => $main::imscpConfig{'ROOT_USER'}, 'group' => $main::imscpConfig{'ROOT_GROUP'}, 'mode' => '0750' }
	);
}

=item _removeLogFolder()

 Remove httpd log folder

 Return int 0 on success, other on failure

=cut

sub _removeLogFolder()
{
	iMSCP::Dir->new(
		'dirname' => "$_[0]->{'httpd'}->{'config'}->{'HTTPD_LOG_DIR'}/$main::imscpConfig{'BASE_SERVER_VHOST'}"
	)->remove();
}

=back

=head1 AUTHOR

 Ninos Ego <me@ninosego.de>

=cut

1;
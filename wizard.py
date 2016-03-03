#!/usr/bin/env python

import sys
import os
import datetime

from pypsi.shell import Shell
from pypsi.core import Command
from pypsi.commands.help import HelpCommand, Topic
from pypsi.commands.tip import TipCommand

from pypsi.plugins.cmd import CmdPlugin

from pypsi import wizard as wiz
from pypsi.os import path_completer
from pypsi.format import Table, Column, title_str

from pypsi.ansi import AnsiCodes
from pypsi import topics

from pypsi.os import find_bins_in_path


class StartWizardCommand(Command):
    '''
    Command to launch startup wizard.
    '''

    def __init__(self, name='quick-setup', **kwargs):
        super(StartWizardCommand, self).__init__(name=name, topic="Setup commands", **kwargs)

    def run(self, shell, args):
        ns = StartWizard.run(shell)
        if ns:
            print()
            Table(
                columns=(
                    Column('Config ID', Column.Shrink),
                    Column('Config Value', Column.Grow)
                ),
                spacing=4
            ).extend(
                ('SSH Key', ns.ssh_key),
            ).write(sys.stdout)
            
            print()    
            exit("\n"
                 "Now run the following command in your terminal: \n" \
                 "docker run -t -i whatever/woot -e SSH_KEY={ssh_key}".format(ssh_key=ns.ssh_key))
        else:
            pass
            
        return 0

StartWizard = wiz.PromptWizard(
    name="Initial Setup",
    description="Configures all neccessary parts to have a running infrastructure",
    steps=(
        wiz.WizardStep(
            id="ssh_key",
            name="Public SSH key",
            help="Absolute path to public ssh key, that will be put in the cloud machines",
            default=os.environ['HOME'] + "/.ssh/id_rsa.pub",
            validators=(wiz.required_validator, wiz.file_validator),
            completer=path_completer
        ),
    )
)


class SecurityWizardCommand(Command):
    '''
    Customize security features.
    '''

    def __init__(self, name='security-setup', **kwargs):
        super(SecurityWizardCommand, self).__init__(name=name, topic="Setup commands", **kwargs)

    def run(self, shell, args):
        ns = ConfigWizard.run(shell)
        if ns:
            print()
            # Create a table with optimally sized columns.
            Table(
                columns=(
                    # FIrst column is the configuration ID. This column will be
                    # the minimum width possible without wrapping
                    Column('Config ID', Column.Shrink),
                    # Second column is the configuration value. This column will
                    # grow to a maximum width possible.
                    Column('Config Value', Column.Grow)
                ),
                # Number of spaces between each column.
                spacing=4
            ).extend(
                # Each tuple is a row
                ('ip_addr', ns.ip_addr),
                ('port', ns.port),
                ('path', ns.path),
                ('mode', ns.mode)
            ).write(sys.stdout) # Write the table to stdout
        else:
            pass

        return 0

ConfigWizard = wiz.PromptWizard(
    name="Mantl Configuration",
    description="Configures all neccessary parts to have a running infrastructure",
    steps=(
        wiz.WizardStep(
            id="ssh_key",
            name="Public SSH key",
            help="Absolute path to public ssh key, that will be put in the cloud machines",
            validators=(wiz.required_validator, wiz.file_validator),
            completer=path_completer
        ),
        wiz.WizardStep(
            id='control_nodes',
            name="How many control nodes do you need?",
            help="TCP port to listen on",
            validators=(wiz.required_validator, wiz.int_validator(1024, 65535)),
            default=3
        ),
        wiz.WizardStep(
            id='path',
            name='File path',
            help='File path to log file',
            validators=wiz.file_validator,
            completer=path_completer
        ),
        wiz.WizardStep(
            id='cloud_provider',
            name='Cloud provider',
            help='Select cloud provider that is supported by terraform',
            default='gce',
            validators=(wiz.required_validator, wiz.choice_validator(['gce', 'aws', 'openstack']))
        )
    )
)

class DemoShell(Shell):
    '''
    Example demonstration shell.
    '''
    wizard_cmd = SecurityWizardCommand()
    quick_wizard = StartWizardCommand()

    cmd_plugin = CmdPlugin()

    help_cmd = HelpCommand()  
    tip_cmd = TipCommand()

    def __init__(self):
        super(DemoShell, self).__init__()

        try:
            self.tip_cmd.load_tips("./demo-tips.txt")
        except:
            self.error("failed to load tips file: demo-tips.txt")

        try:
            self.tip_cmd.load_motd("./demo-motd.txt")
        except:
            self.tip_cmd.motd = "If this is first time running, type 'help' for help and launch a wizard." 

        self.prompt = "{cyan}Mantl{r} {gray}[{status}]{r} {green})>{r} ".format(
            gray=AnsiCodes.gray.prompt(), r=AnsiCodes.reset.prompt(),
            cyan=AnsiCodes.cyan.prompt(), green=AnsiCodes.green.prompt(),
            status='CTL: 0 WOR:0'
        )

        self.help_cmd.add_topic(self, Topic("shell", "Builtin Shell Commands"))
        self._sys_bins = ['quick-setup']

    def on_cmdloop_begin(self):
        print(AnsiCodes.clear_screen)
        if self.tip_cmd.motd:
            self.tip_cmd.print_motd(self)
            print()
        else:
            print("No tips registered. Create the demo-tips.txt file for the tip of the day.")

        if self.tip_cmd.tips:
            print(AnsiCodes.green, "Tip of the Day".center(self.width), sep='')
            print('>' * self.width, AnsiCodes.reset, sep='')
            self.tip_cmd.print_random_tip(self, False)
            print(AnsiCodes.green, '<' * self.width, AnsiCodes.reset, sep='')
            print()
        else:
            #print("To see the message of the day. Create the demo-motd.txt file for the MOTD.")
            pass

    def get_command_name_completions(self, prefix):
        if not self._sys_bins:
            self._sys_bins = find_bins_in_path()

        return sorted(
            [name for name in self.commands if name.startswith(prefix)] +
            [name for name in self._sys_bins if name.startswith(prefix)]
        )


if __name__ == '__main__':
    shell = DemoShell()
    rc = shell.cmdloop()
    sys.exit(rc)

#!/usr/bin/python

import argparse
import sys
import os

try:
    import json
except ImportError:
    import simplejson as json

class DynamicInventory(object):

    def __init__(self):
        if 'ANSIBLE_HOST' not in os.environ:
            print "Please make sure that ANSIBLE_HOST is defined."
            sys.exit(1)
        if 'ANSIBLE_GROUPS' not in os.environ:
            print "Please make sure that ANSIBLE_GROUPS is defined."
            sys.exit(1)

        self.parse_cli_args()

        data_to_print = "{}"

        if self.args.list:
            self.inventory = dict()
            self.load_inventory()
            data_to_print = self.json_format_dict(self.inventory, True)

        print data_to_print

    def parse_cli_args(self):
        parser = argparse.ArgumentParser(description='Produce an Ansible Inventory file based on Environment variables')
        parser.add_argument('--list', action='store_true', default=True, help='List instances (default: True)')
        parser.add_argument('--host', action='store', help='Get all the variables about a specific instance')
        self.args = parser.parse_args()

    def load_inventory(self):
        host = os.environ['ANSIBLE_HOST']
        for group in os.environ['ANSIBLE_GROUPS'].split(','):
            self.inventory[group] = dict()
            self.inventory[group]['hosts'] = [host]

    def json_format_dict(self, data, pretty=False):
        if pretty:
            return json.dumps(data, sort_keys=True, indent=2)
        else:
            return json.dumps(data)

DynamicInventory()

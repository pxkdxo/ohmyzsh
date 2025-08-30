#!/usr/bin/env python3
"""
Retrieve and display a random joke from official-joke-api.appspot.com
"""
from argparse import ArgumentParser
from os import path
from requests import exceptions, get
from sys import argv, exit, stdout
from time import sleep

CATEGORY = 'programming'
API = 'https://official-joke-api.appspot.com/jokes'

if __name__ == '__main__':
    try:
        parser = ArgumentParser(prog=path.basename(argv[0]))
        parser.add_argument('-s', '--sleep', default=0, type=float,
                            help='number of seconds to delay the punchline')
        parser.add_argument('-t', '--timeout', default=1, type=float,
                            help='number of seconds to wait for a response')
        parser.add_argument('category', default=CATEGORY, nargs='?',
                            help='category from which to get a random joke')
        args = parser.parse_args()
        try:
            resp = get(f'{API}/{args.category}/random', timeout=args.timeout)
        except exceptions.ReadTimeout:
            exit(1)
        joke = resp.json()[0]
        print(joke['setup'])
        stdout.flush()
        sleep(args.sleep)
        print(joke['punchline'])
        stdout.flush()
        sleep(args.sleep / 2)
    except KeyboardInterrupt:
        exit(130)

#!/usr/bin/env python3

# Copyright (C) 2021-2022  Jimmy Aguilar Mena

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys, os, re
from statistics import mean, stdev
import pandas as pd

import matplotlib.pyplot as plt

# Comments like: # Anything
re_comment = re.compile('^#(?P<next> -+$)?(?P<report> =+$)?(?P<done> Done:  .+$)?')

re_pair = re.compile('^(?P<key>\w+): (?P<value>.+)$')   # KEY: value
re_number = re.compile('^(?P<number>[+-]?\d+(?P<float>(\.\d+)?([Ee][+-]\d+)?)?)$') # KEY: number
re_string = re.compile('^"(?P<string>.+?)"$') # KEY: "string"

re_done = re.compile('')

results = {}

def process_group(a_dict):
    """Process group of executions with same parameters."""

    copydic :dict = {}
    for key in a_dict:
        assert(isinstance(a_dict[key], list))
        vals_list :list = a_dict[key]
        count :int = len(vals_list)
        assert count > 0, "List shouldn't be empty"

        if "executions" in copydic:
            assert copydic["executions"] == count, "Unmatched array size"
        else:
            copydic["executions"] = count

        if all(isinstance(i, (str, int)) for i in vals_list) :
            # int and string are keys and should all be the same.
            assert all(i == vals_list[0] for i in vals_list), "Failed `all' instances!"
            copydic[key] = vals_list[0]
        elif all(isinstance(i, float) for i in vals_list) :  # Floats
            # floats are values to average.
            copydic[key] = mean(vals_list)
            copydic[key + "_stdev"] = stdev(vals_list) if count > 1 else 0
        else:
            sys.exit("List with mixed or unknown types: " + str(vals_list))

    exe = copydic.pop("Executable")
    assert exe
    results.setdefault(os.path.basename(exe), []).append(copydic)


def process_file(input_file):
    """Process the files and stores the data in a map."""

    line_dict :dict = {}
    count :int = 0

    for line in input_file:
        # Commented lines
        match = re_comment.match(line)
        if match:
            if match.group('next'):         # -------------- repetition
                count = count + 1
            elif match.group('report'):     # ============== end group
                if count > 0:
                    process_group(line_dict)
                    line_dict = {}
                    count = 0
            elif match.group('done'):
                print("Fully executed!")
                break
            continue

        # A pair value is always attached.
        pair = re_pair.match(line)
        if pair:
            key :str = pair.group('key')
            strvalue :str = pair.group('value')

            match = re_number.match(strvalue)
            if match:
                if match.group('float'):              # it is a float so will be averaged later
                    value :float = float(match.group('number'))
                else:                                  # it is a key so will be used as a key/info
                    value :int = int(match.group('number'))
            else:
                match = re_string.match(strvalue)
                if match:
                    value :str = match.group('string')    # remove the " around string
                else:
                    sys.exit("Value type with unknown regex: " + str(key) + " = " + str(strvalue))

            # Create or append
            line_dict.setdefault(key, []).append(value)
            continue

    if count > 0:  # Lines ended, so this is the end hook
        process_group(line_dict)

known_complexities = {
    "cholesky" : lambda x: (x**3)/3.0,
    "matmul" : lambda x: 2*(x**3),
    "matvec" : lambda x: 2*(x**2),
    "jacobi" : lambda x: 2*(x**2)
}

if __name__ == "__main__":
    for filename in sys.argv[1:]:
        if not os.path.isfile(filename):
            print("# Wrong filename: ", filename, file=stderr)
            continue

        results = {}
        # parse file
        print("Processing:", filename, end=' ')
        try:
            with open(filename) as fin:
                process_file(fin)
            print("Ok")
        except IOError:
            print("Couldn't read input:", filename, file = sys.stderr)

        # Get experiment name
        m = re.match(r".+_(\w+)\.txt$", filename)
        assert(m);
        assert(m.group(1) in known_complexities)
        comp = known_complexities[m.group(1)]

        # Create figure
        fig = plt.figure()
        ax = fig.add_subplot(1, 1, 1)

        ax.set_xlabel('Nodes')
        ax.set_ylabel("GFLOPS")
        ax.grid(color='b', ls = '-.', lw = 0.25)

        # Calculate performance, error and add plot line
        for index in results:
            df = pd.DataFrame(results[index],
                              columns = ['Rows', 'Iterations', 'worldsize', 'executions',
                                         'Algorithm_time', 'Algorithm_time_stdev'])

            df['Algorithm_time_err'] = df['Algorithm_time_stdev'] / df["executions"]**(1/2)
            df['GFLOPS'] = df['Rows'].apply(comp) * df['Iterations'] / df['Algorithm_time']
            df['GFLOPS_ERR'] = df['GFLOPS'] * df['Algorithm_time_err'] / df['Algorithm_time']

            print(index)
            print(df)

            ax.errorbar(df['worldsize'], df['GFLOPS'], df['GFLOPS_ERR'],
                        fmt='o-', linewidth=1, markersize=2, label=index)

        # Save the image as a png
        ax.legend()
        image = os.path.basename(filename).split('.')[0] + ".png"
        print("# Saving graph:", image)
        fig.savefig(image, dpi=300, format='png', bbox_inches='tight')

"""Script for computing weeks/quarters since joining parsely."""
import datetime
import math
import sys

format_data = "%Y-%m-%d"
date1 = datetime.datetime.strptime(sys.argv[1], format_data).date()

date2 = datetime.date(2021, 9, 13)

delta = date1 - date2
weeks = math.ceil(delta.days / 7)
quarter = math.ceil(weeks / 13)
print("Weeks: ", weeks)
print("Quarter: ", quarter)
print("Next quarter: ", quarter * 13)

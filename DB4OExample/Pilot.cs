using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DB4OExample
{
    public class Pilot
    {
        public string Name { get; set; }
        public double Score { get; set; }
        public Pilot(string name, double score)
        {
            Name = name; Score = score;
        }

        public void AddPoint(double score)
        {
            Score += score;
        }

        public override string ToString()
        {
            return string.Format("{0}/{1}", Name, Score);
        }
    }
}

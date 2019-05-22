using Db4objects.Db4o;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DB4OExample
{
    public class DatabaseHelper
    {
        public static string DbFileName { get; set; }
        public static void Add(object obj)
        {
            IObjectContainer db = Db4oEmbedded.OpenFile(DbFileName);
            db.Store(obj);
            db.Close();
        }

        public static List<T> GetList<T>()
        {
            List<T> results = new List<T>();

            IObjectContainer db = Db4oEmbedded.OpenFile(DbFileName);
            Pilot template = new Pilot(null, 0);
            IObjectSet resultList = db.QueryByExample(template);
            foreach (T obj in resultList)
            {
                results.Add(obj);
            }
            db.Close();
            return results;
        }

        public static void UpdatePilot(Pilot plUpdate)
        {
            IObjectContainer db = Db4oEmbedded.OpenFile(DbFileName);
            //Tìm theo tên
            Pilot template = new Pilot(plUpdate.Name, 0);
            IObjectSet resultList = db.QueryByExample(template);
            //giả sử tìm được 1 phần tử duy nhất
            Pilot pilot = resultList[0] as Pilot;
            pilot.Score = template.Score;
            db.Store(pilot);
            db.Close();
        }

        public static void DeletePilot(string name)
        {
            IObjectContainer db = Db4oEmbedded.OpenFile(DbFileName);
            //Tìm theo tên
            Pilot template = new Pilot(name, 0);
            IObjectSet resultList = db.QueryByExample(template);
            //giả sử tìm được 1 phần tử duy nhất
            Pilot pilot = resultList[0] as Pilot;
            pilot.Score = template.Score;
            db.Delete(pilot);
            db.Close();
        }

        public static List<Pilot> Search(string name, double score)
        {
            List<Pilot> kq = new List<Pilot>();

            //tìm gần đúng theo name và điểm >= score
            IObjectContainer db = Db4oEmbedded.OpenFile(DbFileName);
            IList<Pilot> pilots = db.Query<Pilot>(delegate (Pilot pilot)
            {
                return (pilot.Name.Contains(name) && pilot.Score >= score);                
            });
            
            kq= pilots.ToList<Pilot>();
            db.Close();
            return kq;
        }
    }
}

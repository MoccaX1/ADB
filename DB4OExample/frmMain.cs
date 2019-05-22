using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DB4OExample
{
    public partial class frmMain : Form
    {
        public frmMain()
        {
            InitializeComponent();
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            Pilot pl = new Pilot(txtName.Text, double.Parse(txtPoint.Text));
            DatabaseHelper.Add(pl);
            UpdateGrid();
        }

        private void frmMain_Load(object sender, EventArgs e)
        {
            DatabaseHelper.DbFileName = "K42ADBWed.yap";
        }

        private void btnUpdate_Click(object sender, EventArgs e)
        {
            Pilot pl = new Pilot(txtName.Text, double.Parse(txtPoint.Text));
            DatabaseHelper.UpdatePilot(pl);

            //gọi update lưới
            UpdateGrid();
        }

        private void UpdateGrid()
        {
            dataGridView1.DataSource = null;
            dataGridView1.DataSource = DatabaseHelper.GetList<Pilot>();
        }

        private void btnLoadMore_Click(object sender, EventArgs e)
        {
            UpdateGrid();
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            dataGridView1.DataSource = null;
            dataGridView1.DataSource = DatabaseHelper.Search(txtName.Text, double.Parse(txtPoint.Text));
        }
    }
}

﻿
namespace QLDeAn
{
     partial class PrivilegeUI
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.grantPrivilege = new System.Windows.Forms.Button();
            this.revokePrivilege = new System.Windows.Forms.Button();
            this.tableLabel = new System.Windows.Forms.Label();
            this.dataGridView2 = new System.Windows.Forms.DataGridView();
            this.colLabel = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.AllowUserToOrderColumns = true;
            this.dataGridView1.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.dataGridView1.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.DisplayedCells;
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Location = new System.Drawing.Point(31, 99);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersWidth = 51;
            this.dataGridView1.RowTemplate.Height = 24;
            this.dataGridView1.Size = new System.Drawing.Size(1201, 230);
            this.dataGridView1.TabIndex = 3;
            this.dataGridView1.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dataGridView1_CellContentClick);
            // 
            // grantPrivilege
            // 
            this.grantPrivilege.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.grantPrivilege.Location = new System.Drawing.Point(30, 12);
            this.grantPrivilege.Name = "grantPrivilege";
            this.grantPrivilege.Size = new System.Drawing.Size(172, 42);
            this.grantPrivilege.TabIndex = 4;
            this.grantPrivilege.Text = "CẤP QUYỀN CHO ROLE/USER";
            this.grantPrivilege.UseCompatibleTextRendering = true;
            this.grantPrivilege.UseVisualStyleBackColor = true;
            this.grantPrivilege.Click += new System.EventHandler(this.grantPrivilege_Click);
            // 
            // revokePrivilege
            // 
            this.revokePrivilege.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.revokePrivilege.Location = new System.Drawing.Point(208, 12);
            this.revokePrivilege.Name = "revokePrivilege";
            this.revokePrivilege.Size = new System.Drawing.Size(172, 42);
            this.revokePrivilege.TabIndex = 5;
            this.revokePrivilege.Text = "HỦY QUYỀN CỦA ROLE/USER";
            this.revokePrivilege.UseCompatibleTextRendering = true;
            this.revokePrivilege.UseVisualStyleBackColor = true;
            this.revokePrivilege.Click += new System.EventHandler(this.revokePrivilege_Click);
            // 
            // tableLabel
            // 
            this.tableLabel.AutoSize = true;
            this.tableLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tableLabel.Location = new System.Drawing.Point(27, 76);
            this.tableLabel.Name = "tableLabel";
            this.tableLabel.Size = new System.Drawing.Size(68, 20);
            this.tableLabel.TabIndex = 6;
            this.tableLabel.Text = "TABLE";
            this.tableLabel.Click += new System.EventHandler(this.label1_Click);
            // 
            // dataGridView2
            // 
            this.dataGridView2.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView2.Location = new System.Drawing.Point(30, 374);
            this.dataGridView2.Name = "dataGridView2";
            this.dataGridView2.RowHeadersWidth = 51;
            this.dataGridView2.RowTemplate.Height = 24;
            this.dataGridView2.Size = new System.Drawing.Size(1201, 230);
            this.dataGridView2.TabIndex = 7;
            // 
            // colLabel
            // 
            this.colLabel.AutoSize = true;
            this.colLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.colLabel.Location = new System.Drawing.Point(27, 351);
            this.colLabel.Name = "colLabel";
            this.colLabel.Size = new System.Drawing.Size(88, 20);
            this.colLabel.TabIndex = 8;
            this.colLabel.Text = "COLUMN";
            this.colLabel.Click += new System.EventHandler(this.colLabel_Click);
            // 
            // PrivilegeUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.colLabel);
            this.Controls.Add(this.dataGridView2);
            this.Controls.Add(this.tableLabel);
            this.Controls.Add(this.revokePrivilege);
            this.Controls.Add(this.grantPrivilege);
            this.Controls.Add(this.dataGridView1);
            this.Name = "PrivilegeUI";
            this.Size = new System.Drawing.Size(1261, 620);
            this.Load += new System.EventHandler(this.UserAndRole_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView2)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        public System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Button grantPrivilege;
        private System.Windows.Forms.Button revokePrivilege;
        private System.Windows.Forms.Label tableLabel;
        public System.Windows.Forms.DataGridView dataGridView2;
        private System.Windows.Forms.Label colLabel;
    }
}

import ExcelJS from "exceljs";

const files = [
    'wfa-boys-zscore-expanded-tables.xlsx',
    'wfa-girls-zscore-expanded-tables.xlsx',
    'lhfa-boys-zscore-expanded-tables.xlsx',
    'lhfa-girls-zscore-expanded-tables.xlsx',
    'wfl-boys-zscore-expanded-tables.xlsx',
    'wfl-girls-zscore-expanded-tables.xlsx',
    'wfh-boys-zscore-expanded-tables.xlsx',
    'wfh-girls-zscore-expanded-tables.xlsx'
]

for (const file of files) {
    console.log(`\n========== ${file} ==========`)

    const workbook = new ExcelJS.Workbook()
    await workbook.xlsx.readFile(`./who-data/${file}`)

    const sheet = workbook.worksheets[0]
    console.log('Sheet name :', sheet.name)

    // Ambil baris header (baris 1)
    const header = []
    sheet.getRow(1).eachCell((cell) => {
        header.push(cell.value)
    })
    console.log('Kolom      :', header)

    // Ambil 2 baris data pertama
    console.log('Baris 2    :', sheet.getRow(2).values)
    console.log('Baris 3    :', sheet.getRow(3).values)
    console.log('Total baris:', sheet.rowCount)
}
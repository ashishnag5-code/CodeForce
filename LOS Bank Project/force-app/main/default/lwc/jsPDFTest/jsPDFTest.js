import { LightningElement } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/jsPDF';
import { loadScript } from 'lightning/platformResourceLoader';
import sresource from "@salesforce/resourceUrl/pdfjs";
export default class JsPDFTest extends LightningElement {
    jsPdfInitialized=false;
    renderedCallback(){
        if (this.jsPdfInitialized) {
            return;
        }
        this.jsPdfInitialized = true;
        loadStyle(this, sresource + "/custom1.css");
        this.viewerUrl = sresource + "/web/viewer.html?file=Document.pdf";
        if (this.showConsoleLogs) {
          console.log({
            log: "renderedCallback",
            viewerUrl: this.viewerUrl
          });
        }
        Promise.all([
            loadScript(this, jsPDF).then(() => {
                console.log("JS loaded");
            }).catch(error => {
                console.error("Error " + error);
            })
            
        ]);
    }
    generatePDF()
    {
        this.generate();
        this.generatePDFImage();
    }
    generate()
    {
        try
        {
            const { jsPDF } = window.jspdf;
            var verticalOffset=0.5;
            var size=12;
            var margin=0.5;

            const doc = new jsPDF('p', 'in', 'letter');
            //Landscape PDF
            //new jsPDF({   orientation: 'landscape',   unit: 'in',   format: [4, 2] })  
            // jsPDF('p', 'in', 'letter')

            //Sets the text color setTextColor(ch1, ch2, ch3, ch4) 
            doc.setTextColor(100); 
            //Create Text
            doc.text("Hello SalesforceCodex!", 10, 10);
            doc.rect(20, 20, 10, 10);
            
            // Set Margins:
            doc.setDrawColor(0, 255, 0)   //Draw Color
            .setLineWidth(1 / 72)  // Paragraph line width
            .line(margin, margin, margin, 11 - margin) // Margins
            .line(8.5 - margin, margin, 8.5 - margin, 11 - margin)

            var stringText='SalesforceCodex.com is started in 2016 as a personal blog where I tried to solve problems with simple and understandable content. Initially, my focus was on sharing content on which feature I was working. \n\nToday, SalesforceCodex.com is focused on helping salesforce developers, programmers and other IT professionals improve their careers. We are helping developers in integrating other technologies,  coding best practices, lightning web components, architecture, design solutions, etc.';
            
            var lines=doc.setFont('Helvetica', 'Italic')
                                .setFontSize(12)
                                .splitTextToSize(stringText, 7.5);
            //doc.setFontSize(40);
            doc.text(0.5, verticalOffset + size / 72, lines);
            verticalOffset += (lines.length + 0.5) * size / 72;
            //Save File
            doc.save("a4.pdf");
            
        }
        catch(error) {
            alert("Error " + error);
        }
    }
    //Convert Image into Base64
    getBase64Image(img) {
        var canvas = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;
        var ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);
        var dataURL = canvas.toDataURL("image/png");
        return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
    }
    
    //Create PDF with Image and Text
    generatePDFImage(e)
    {
        try{
            const { jsPDF } = window.jspdf;
            // You'll need to make your image into a Data URL
            var imgData = 'data:image/jpeg;base64,'+ this.getBase64Image(this.template.querySelector('.image'));            
            var doc = new jsPDF();
            doc.setFontSize(40);
            doc.text(35, 25, 'SalesforceCodex.com');
            doc.addImage(imgData, 'JPEG', 15, 40, 180, 160);
            doc.save("a4.pdf");
        }
        catch(error)
        {
            alert(error);
        }
    }
}
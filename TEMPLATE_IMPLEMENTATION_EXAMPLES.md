# Template Download Feature - Implementation Examples

## 🎨 Visual Mockup - Enhanced Download Modal

### Current Modal (Simple Download)
```
┌─────────────────────────────────────────────────────────┐
│  Download QR Code                              [×]      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────────────────┐       │
│  │  QR Code Preview                             │       │
│  │  ┌─────────┐                                 │       │
│  │  │  [QR]   │  My QR Code                     │       │
│  │  │  Code   │  Event QR                       │       │
│  │  └─────────┘                                 │       │
│  └─────────────────────────────────────────────┘       │
│                                                         │
│  Select Format:                                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│
│  │   PNG    │ │   JPG    │ │   JPEG   │ │   SVG    ││
│  │ Lossless │ │Compressed│ │ Standard │ │ Vector   ││
│  │    ✓     │ │          │ │          │ │          ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘│
│                                                         │
│  [Download PNG]                                         │
└─────────────────────────────────────────────────────────┘
```

### Enhanced Modal (With Template Mode)
```
┌─────────────────────────────────────────────────────────┐
│  Download QR Code                              [×]      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐ ┌──────────────┐                      │
│  │  Simple      │ │  Template    │ ← Active             │
│  └──────────────┘ └──────────────┘                      │
│                                                         │
│  Template Category:                                     │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐   │
│  │ Business Card │ │   Flyer      │ │   Poster     │   │
│  │      ✓        │ │              │ │              │   │
│  └──────────────┘ └──────────────┘ └──────────────┘   │
│  ┌──────────────┐ ┌──────────────┐                    │
│  │    Label     │ │ Social Media │                    │
│  └──────────────┘ └──────────────┘                    │
│                                                         │
│  Available Templates:                                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│
│  │[Preview] │ │[Preview] │ │[Preview] │ │[Preview] ││
│  │Template 1│ │Template 2│ │Template 3│ │Template 4││
│  │  ✓       │ │          │ │          │ │          ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘│
│                                                         │
│  Customization:                                         │
│  • Background: [Color Picker: #FFFFFF]                 │
│  • Text Color: [Color Picker: #000000]                │
│  • Company Name: [Acme Corporation        ]            │
│  • Tagline: [Your Trusted Partner        ]            │
│  • QR Size: [Small] [Medium] [Large] ✓                │
│                                                         │
│  Live Preview:                                         │
│  ┌─────────────────────────────────────────────┐       │
│  │                                             │       │
│  │  [Template Preview with QR Code]            │       │
│  │                                             │       │
│  └─────────────────────────────────────────────┘       │
│                                                         │
│  Format: [PNG ▼]                                       │
│  [Download with Template]                              │
└─────────────────────────────────────────────────────────┘
```

---

## 💻 Code Examples

### 1. Template Interface Definition

```typescript
// models/qr-template.model.ts

export interface QRTemplate {
  id: string;
  name: string;
  description: string;
  category: TemplateCategory;
  thumbnail: string;
  dimensions: TemplateDimensions;
  layout: TemplateLayout;
  customizable: TemplateCustomizable;
  defaultValues: TemplateDefaults;
}

export type TemplateCategory = 
  | 'business-card' 
  | 'flyer' 
  | 'poster' 
  | 'label' 
  | 'social-media';

export interface TemplateDimensions {
  width: number;
  height: number;
  unit: 'px' | 'mm' | 'in';
  dpi?: number; // For print quality
}

export interface TemplateLayout {
  type: 'html' | 'canvas';
  htmlFile?: string; // Path to HTML template
  cssFile?: string; // Path to CSS file
  htmlContent?: string; // Inline HTML
  cssContent?: string; // Inline CSS
  qrPlaceholder: string; // e.g., '{{QR_CODE}}'
  textPlaceholders: { [key: string]: string }; // e.g., '{{COMPANY_NAME}}'
}

export interface TemplateCustomizable {
  colors: ColorField[];
  text: TextField[];
  images?: ImageField[];
  layout?: LayoutOption[];
}

export interface ColorField {
  id: string;
  label: string;
  default: string;
  cssProperty: string; // e.g., 'background-color'
  selector: string; // CSS selector
}

export interface TextField {
  id: string;
  label: string;
  placeholder: string;
  default: string;
  maxLength?: number;
  multiline?: boolean;
}

export interface LayoutOption {
  id: string;
  label: string;
  value: any;
}

export interface TemplateDefaults {
  colors: { [key: string]: string };
  text: { [key: string]: string };
  layout?: { [key: string]: any };
}

export interface TemplateCustomization {
  templateId: string;
  colors: { [key: string]: string };
  text: { [key: string]: string };
  layout?: { [key: string]: any };
}
```

### 2. Template Repository Example

```typescript
// services/qr-template.service.ts

import { Injectable } from '@angular/core';
import { QRTemplate, TemplateCategory } from '../models/qr-template.model';

@Injectable({
  providedIn: 'root'
})
export class QRTemplateService {
  private templates: QRTemplate[] = [
    {
      id: 'business-card-1',
      name: 'Classic Business Card',
      description: 'Traditional layout with QR code in top-left corner',
      category: 'business-card',
      thumbnail: 'assets/templates/business-card/template-1-thumb.png',
      dimensions: {
        width: 85.6,
        height: 53.98,
        unit: 'mm',
        dpi: 300
      },
      layout: {
        type: 'html',
        htmlFile: 'assets/templates/business-card/template-1.html',
        cssFile: 'assets/templates/business-card/template-1.css',
        qrPlaceholder: '{{QR_CODE}}',
        textPlaceholders: {
          '{{COMPANY_NAME}}': 'companyName',
          '{{PERSON_NAME}}': 'personName',
          '{{TITLE}}': 'title',
          '{{PHONE}}': 'phone',
          '{{EMAIL}}': 'email',
          '{{WEBSITE}}': 'website'
        }
      },
      customizable: {
        colors: [
          {
            id: 'backgroundColor',
            label: 'Background Color',
            default: '#FFFFFF',
            cssProperty: 'background-color',
            selector: '.card-background'
          },
          {
            id: 'textColor',
            label: 'Text Color',
            default: '#000000',
            cssProperty: 'color',
            selector: '.card-text'
          }
        ],
        text: [
          {
            id: 'companyName',
            label: 'Company Name',
            placeholder: 'Enter company name',
            default: '',
            maxLength: 50
          },
          {
            id: 'personName',
            label: 'Your Name',
            placeholder: 'Enter your name',
            default: '',
            maxLength: 50
          },
          {
            id: 'title',
            label: 'Job Title',
            placeholder: 'Enter job title',
            default: '',
            maxLength: 50
          },
          {
            id: 'phone',
            label: 'Phone',
            placeholder: '+1 (555) 123-4567',
            default: '',
            maxLength: 20
          },
          {
            id: 'email',
            label: 'Email',
            placeholder: 'your@email.com',
            default: '',
            maxLength: 100
          },
          {
            id: 'website',
            label: 'Website',
            placeholder: 'www.example.com',
            default: '',
            maxLength: 100
          }
        ]
      },
      defaultValues: {
        colors: {
          backgroundColor: '#FFFFFF',
          textColor: '#000000'
        },
        text: {
          companyName: '',
          personName: '',
          title: '',
          phone: '',
          email: '',
          website: ''
        }
      }
    },
    // Add more templates...
  ];

  getTemplatesByCategory(category: TemplateCategory): QRTemplate[] {
    return this.templates.filter(t => t.category === category);
  }

  getTemplateById(id: string): QRTemplate | undefined {
    return this.templates.find(t => t.id === id);
  }

  getAllCategories(): TemplateCategory[] {
    return Array.from(new Set(this.templates.map(t => t.category)));
  }
}
```

### 3. Template Renderer Example

```typescript
// services/template-renderer.service.ts

import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import html2canvas from 'html2canvas';
import { QRTemplate, TemplateCustomization } from '../models/qr-template.model';

@Injectable({
  providedIn: 'root'
})
export class TemplateRendererService {
  constructor(private http: HttpClient) {}

  async renderTemplate(
    template: QRTemplate,
    qrCodeImageUrl: string,
    customization: TemplateCustomization
  ): Promise<string> {
    // 1. Load template HTML
    let html = await this.loadTemplateHTML(template);
    let css = await this.loadTemplateCSS(template);

    // 2. Replace placeholders
    html = this.replacePlaceholders(html, template, qrCodeImageUrl, customization);

    // 3. Create temporary DOM element
    const container = document.createElement('div');
    container.style.position = 'absolute';
    container.style.left = '-9999px';
    container.style.width = `${template.dimensions.width}${template.dimensions.unit}`;
    container.style.height = `${template.dimensions.height}${template.dimensions.unit}`;
    
    // Inject styles
    const styleElement = document.createElement('style');
    styleElement.textContent = css;
    container.appendChild(styleElement);

    // Inject HTML
    container.innerHTML += html;
    document.body.appendChild(container);

    // 4. Apply customizations
    this.applyCustomizations(container, template, customization);

    // 5. Render to canvas
    const canvas = await html2canvas(container, {
      scale: 3, // High quality
      useCORS: true,
      backgroundColor: null,
      width: this.convertToPixels(template.dimensions.width, template.dimensions.unit, template.dimensions.dpi || 300),
      height: this.convertToPixels(template.dimensions.height, template.dimensions.unit, template.dimensions.dpi || 300)
    });

    // 6. Cleanup
    document.body.removeChild(container);

    // 7. Return as data URL
    return canvas.toDataURL('image/png', 1.0);
  }

  private async loadTemplateHTML(template: QRTemplate): Promise<string> {
    if (template.layout.htmlContent) {
      return template.layout.htmlContent;
    }
    if (template.layout.htmlFile) {
      const response = await this.http.get(template.layout.htmlFile, { responseType: 'text' }).toPromise();
      return response as string;
    }
    throw new Error('Template HTML not found');
  }

  private async loadTemplateCSS(template: QRTemplate): Promise<string> {
    if (template.layout.cssContent) {
      return template.layout.cssContent;
    }
    if (template.layout.cssFile) {
      const response = await this.http.get(template.layout.cssFile, { responseType: 'text' }).toPromise();
      return response as string;
    }
    return '';
  }

  private replacePlaceholders(
    html: string,
    template: QRTemplate,
    qrCodeImageUrl: string,
    customization: TemplateCustomization
  ): string {
    // Replace QR code
    html = html.replace(template.layout.qrPlaceholder, `<img src="${qrCodeImageUrl}" alt="QR Code" class="qr-code-image">`);

    // Replace text placeholders
    Object.keys(template.layout.textPlaceholders).forEach(placeholder => {
      const fieldId = template.layout.textPlaceholders[placeholder];
      const value = customization.text[fieldId] || template.defaultValues.text[fieldId] || '';
      html = html.replace(new RegExp(placeholder, 'g'), value);
    });

    return html;
  }

  private applyCustomizations(
    container: HTMLElement,
    template: QRTemplate,
    customization: TemplateCustomization
  ): void {
    // Apply color customizations
    template.customizable.colors.forEach(colorField => {
      const elements = container.querySelectorAll(colorField.selector);
      elements.forEach((el: HTMLElement) => {
        const color = customization.colors[colorField.id] || colorField.default;
        (el.style as any)[colorField.cssProperty] = color;
      });
    });
  }

  private convertToPixels(value: number, unit: string, dpi: number = 300): number {
    switch (unit) {
      case 'mm':
        return (value / 25.4) * dpi;
      case 'in':
        return value * dpi;
      case 'px':
      default:
        return value;
    }
  }
}
```

### 4. Component Example - Template Download Modal

```typescript
// shared/qr-template-download/qr-template-download.component.ts

import { Component, Input, Output, EventEmitter } from '@angular/core';
import { QRCodeData } from '../../../models/qr-code.model';
import { QRTemplate, TemplateCategory, TemplateCustomization } from '../../../models/qr-template.model';
import { QRTemplateService } from '../../../services/qr-template.service';
import { TemplateRendererService } from '../../../services/template-renderer.service';

@Component({
  selector: 'app-qr-template-download',
  templateUrl: './qr-template-download.component.html',
  styleUrls: ['./qr-template-download.component.scss']
})
export class QRTemplateDownloadComponent {
  @Input() qrCode!: QRCodeData;
  @Output() close = new EventEmitter<void>();
  @Output() download = new EventEmitter<string>(); // Emits data URL

  selectedCategory: TemplateCategory = 'business-card';
  selectedTemplate?: QRTemplate;
  customization: TemplateCustomization = {
    templateId: '',
    colors: {},
    text: {}
  };
  previewUrl?: string;
  selectedFormat: 'png' | 'jpg' | 'pdf' = 'png';
  isGenerating = false;

  categories: TemplateCategory[] = [];
  templates: QRTemplate[] = [];

  constructor(
    private templateService: QRTemplateService,
    private rendererService: TemplateRendererService
  ) {
    this.categories = this.templateService.getAllCategories();
    this.loadTemplates();
  }

  onCategoryChange(category: TemplateCategory): void {
    this.selectedCategory = category;
    this.loadTemplates();
    this.selectedTemplate = undefined;
  }

  onTemplateSelect(template: QRTemplate): void {
    this.selectedTemplate = template;
    this.customization.templateId = template.id;
    this.initializeCustomization(template);
    this.generatePreview();
  }

  onCustomizationChange(): void {
    if (this.selectedTemplate) {
      this.generatePreview();
    }
  }

  private loadTemplates(): void {
    this.templates = this.templateService.getTemplatesByCategory(this.selectedCategory);
  }

  private initializeCustomization(template: QRTemplate): void {
    // Initialize with defaults
    template.customizable.colors.forEach(color => {
      this.customization.colors[color.id] = color.default;
    });
    template.customizable.text.forEach(text => {
      this.customization.text[text.id] = text.default;
    });
  }

  private async generatePreview(): Promise<void> {
    if (!this.selectedTemplate || !this.qrCode) return;

    this.isGenerating = true;
    try {
      // Get QR code image
      const qrImageUrl = this.qrCode.compositeImageData || this.qrCode.imageUrl || '';
      
      // Render template
      this.previewUrl = await this.rendererService.renderTemplate(
        this.selectedTemplate,
        qrImageUrl,
        this.customization
      );
    } catch (error) {
      console.error('Error generating preview:', error);
    } finally {
      this.isGenerating = false;
    }
  }

  async onDownload(): Promise<void> {
    if (!this.selectedTemplate || !this.previewUrl) return;

    this.isGenerating = true;
    try {
      // Re-render at full quality
      const qrImageUrl = this.qrCode.compositeImageData || this.qrCode.imageUrl || '';
      const fullQualityUrl = await this.rendererService.renderTemplate(
        this.selectedTemplate,
        qrImageUrl,
        this.customization
      );

      this.download.emit(fullQualityUrl);
      this.close.emit();
    } catch (error) {
      console.error('Error downloading template:', error);
    } finally {
      this.isGenerating = false;
    }
  }

  onClose(): void {
    this.close.emit();
  }
}
```

### 5. HTML Template Example

```html
<!-- assets/templates/business-card/template-1.html -->
<div class="business-card">
  <div class="card-background">
    <div class="card-header">
      <div class="qr-section">
        {{QR_CODE}}
      </div>
      <div class="logo-section">
        <!-- Logo placeholder -->
      </div>
    </div>
    <div class="card-body">
      <h1 class="company-name">{{COMPANY_NAME}}</h1>
      <div class="person-info">
        <h2 class="person-name">{{PERSON_NAME}}</h2>
        <p class="person-title">{{TITLE}}</p>
      </div>
      <div class="contact-info">
        <p class="contact-item">
          <i class="bi bi-telephone"></i>
          <span>{{PHONE}}</span>
        </p>
        <p class="contact-item">
          <i class="bi bi-envelope"></i>
          <span>{{EMAIL}}</span>
        </p>
        <p class="contact-item">
          <i class="bi bi-globe"></i>
          <span>{{WEBSITE}}</span>
        </p>
      </div>
    </div>
  </div>
</div>
```

### 6. CSS Template Example

```css
/* assets/templates/business-card/template-1.css */
.business-card {
  width: 85.6mm;
  height: 53.98mm;
  padding: 0;
  margin: 0;
  box-sizing: border-box;
}

.card-background {
  width: 100%;
  height: 100%;
  background-color: #FFFFFF; /* Customizable */
  border-radius: 4px;
  padding: 5mm;
  display: flex;
  flex-direction: column;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 3mm;
}

.qr-section {
  width: 20mm;
  height: 20mm;
}

.qr-section img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.logo-section {
  width: 15mm;
  height: 15mm;
  background: #f0f0f0;
  border-radius: 2px;
}

.card-body {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.company-name {
  font-size: 8pt;
  font-weight: bold;
  color: #000000; /* Customizable */
  margin: 0 0 2mm 0;
}

.person-info {
  margin-bottom: 2mm;
}

.person-name {
  font-size: 10pt;
  font-weight: bold;
  color: #000000; /* Customizable */
  margin: 0 0 1mm 0;
}

.person-title {
  font-size: 7pt;
  color: #666666; /* Customizable */
  margin: 0;
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 1mm;
}

.contact-item {
  font-size: 6pt;
  color: #000000; /* Customizable */
  margin: 0;
  display: flex;
  align-items: center;
  gap: 2mm;
}

.contact-item i {
  font-size: 7pt;
}
```

---

## 🚀 Quick Start Implementation

### Step 1: Install Dependencies
```bash
npm install html2canvas
npm install @types/html2canvas --save-dev
```

### Step 2: Create Basic Template
1. Create `assets/templates/business-card/template-1.html`
2. Create `assets/templates/business-card/template-1.css`
3. Add template definition to service

### Step 3: Integrate into Download Modal
1. Add tab toggle (Simple/Template)
2. Add template selector component
3. Add customization panel
4. Add preview component

### Step 4: Test
1. Test with one template
2. Verify export quality
3. Test customization
4. Expand to more templates

---

This provides a solid foundation for implementing the template download feature!


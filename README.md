# Printer Gateway

A Flutter package that converts JSON data into formatted receipts/documents. It supports rendering as widgets, images, and printer-ready formats for both POS and ESC/POS printers.

[![pub package](https://img.shields.io/pub/v/printer_gateway.svg)](https://pub.dev/packages/printer_gateway)

## Why This Package?

**The Problem:** When printing receipts line-by-line or using device-specific SDK methods across different thermal printers, the same receipt often appears inconsistent. Issues arise from:

- **Different fonts** between printer models
- **Varying spacing and margins** across devices
- **Inconsistent rendering** of the same print commands
- **SDK-specific behaviors** that differ by manufacturer

**The Solution:** Printer Gateway solves these inconsistencies by generating a **single, unified image** from your JSON data. This ensures that every receipt prints **exactly the same** on any device, regardless of the printer model, SDK, or manufacturer. By converting your receipt layout to an image first, you eliminate variability and gain complete control over the final output.

## Features

- 📄 **JSON to Widget**: Convert JSON receipt data into Flutter widgets
- 🖼️ **JSON to Image**: Generate image representation of receipts
- 🖨️ **Printer Support**: Export to POS and ESC/POS printer formats
- 🎨 **Rich Formatting**: Support for text styling, alignment, tables, QR codes, and more
- 📐 **Flexible Layouts**: Single lines, columns, tables with headers and items
- 🔧 **Customizable**: Add header/footer images, adjust margins and widths

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  printer_gateway: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Getting Started

### Basic Usage

```dart
import 'package:printer_gateway/printer_gateway.dart';

// Create an instance with JSON data
final printerGateway = PrinterGateway(
  jsonData: jsonString, // Your JSON receipt data
);

// Optional: Add header and footer images
printerGateway.addHeaderImage(headerImageBytes);
printerGateway.addFooterImage(footerImageBytes);
```

## Available Methods

### 1. `toWidget()`

Converts JSON data into a Flutter Widget for display in your app.

**Parameters:**
- `maxWidth` (double, optional): Maximum width of the widget. Default: `576`
- `margin` (int, optional): Horizontal margin/padding. Default: `0`

**Returns:** `Widget`

**Example:**
```dart
Widget receiptWidget = printerGateway.toWidget(
  maxWidth: 576,
  margin: 10,
);

// Use in your widget tree
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: receiptWidget,
    ),
  );
}
```

---

### 2. `toImage()`

Generates a single image (Uint8List) from the JSON receipt data.

**Parameters:**
- `context` (BuildContext, required): Build context for rendering
- `maxWidth` (double, optional): Width of the generated image. Default: `576`
- `margin` (int, optional): Horizontal margin. Default: `0`
- `fixedRatio` (double, optional): Pixel ratio for image quality. Default: `0` (auto)

**Returns:** `Future<Uint8List>`

**Example:**
```dart
// Generate receipt image
Uint8List imageBytes = await printerGateway.toImage(
  context,
  maxWidth: 576,
  margin: 0,
  fixedRatio: 2.0, // Higher value = better quality
);

// Save to file or display
File('receipt.png').writeAsBytesSync(imageBytes);
```

---

### 3. `toPosPrinter()`

Converts the receipt into a list of image parts suitable for POS printers. Automatically splits long receipts into chunks.

**Parameters:**
- `context` (BuildContext, required): Build context for rendering
- `maxHeight` (int, optional): Maximum height per image chunk. Default: `2000`
- `maxWidth` (double, optional): Width of each image. Default: `576`
- `margin` (int, optional): Horizontal margin. Default: `0`
- `fixedRatio` (double, optional): Pixel ratio. Default: `0` (auto)

**Returns:** `Future<List<Uint8List>>`

**Example:**
```dart
List<Uint8List> imageParts = await printerGateway.toPosPrinter(
  context,
  maxHeight: 2000,
  maxWidth: 384, // Common POS printer width
);

// Send each part to your POS printer
for (var imagePart in imageParts) {
  await yourPrinterService.printImage(imagePart);
}
```

---

### 4. `toEscPosPrinter()`

Converts the receipt into decoded Image objects from the `image` package, suitable for ESC/POS printers.

**Parameters:**
- `context` (BuildContext, required): Build context for rendering
- `maxHeight` (int, optional): Maximum height per image chunk. Default: `2000`
- `maxWidth` (double, optional): Width of each image. Default: `576`
- `margin` (int, optional): Horizontal margin. Default: `0`
- `fixedRatio` (double, optional): Pixel ratio. Default: `0` (auto)

**Returns:** `Future<List<decoder.Image>>` (where `decoder` is from `package:image/image.dart`)

**Example:**
```dart
import 'package:image/image.dart' as img;

List<img.Image> rasterImages = await printerGateway.toEscPosPrinter(
  context,
  maxHeight: 2000,
  maxWidth: 384,
);

// Process with your ESC/POS library
for (var rasterImage in rasterImages) {
  // Convert to ESC/POS commands
  await escPosPrinter.printRaster(rasterImage);
}
```

---

## JSON Structure

The package uses a JSON array where each object represents a line in the receipt. Each line can have different types of content.

### Basic Line Types

#### 1. Simple Text Line

A basic text line with customization options.

```json
{
  "line": {
    "customization": {
      "font_style": {
        "bold": true,
        "italic": false
      },
      "font_size": 18,
      "alignment": 1
    },
    "content": "MY TEXT HERE"
  }
}
```

**Customization Properties:**
- `font_style`: Object containing `bold` (boolean) and `italic` (boolean)
- `font_size`: Number (default text size is around 12)
- `alignment`: Number
  - `0` = Left aligned
  - `1` = Center aligned
  - `2` = Right aligned
  - `3` = Justified
- `content`: String - The text to display
- `sensive_content`: String (optional) - Sensitive data that will be automatically obscured
- `reverse`: Boolean (optional) - If true, displays white text on black background
- `font_name`: String (optional) - Custom font family name

**Obscuring Sensitive Content:**

When you need to display sensitive information (like credit card numbers, passwords, or personal data) in a partially hidden format, use the `sensive_content` property along with `content`:

```json
{
  "line": {
    "customization": {
      "font_style": {
        "bold": false,
        "italic": false
      },
      "font_size": 12,
      "alignment": 0
    },
    "content": "Card Number: ",
    "sensive_content": "1234567890123456"
  }
}
```

**Output:** `Card Number:  123**********56`

**Obscuring Rules:**
- Strings with 1-2 characters: Shows first and last character with asterisks in between
- Strings with 3+ characters: Shows first 3 characters and last 2 characters, obscures the rest with asterisks
- Example: "1234567890" becomes " 123*****90"
- Example: "password123" becomes " pas******23"

---

#### 2. Divider Line

A horizontal separator line.

```json
{
  "line": {
    "divider": true
  }
}
```

---

#### 3. QR Code

Generates a QR code in the receipt.

```json
{
  "line": {
    "qrcode": {
      "size": 150,
      "content": "https://example.com/receipt/12345",
      "level": "L"
    }
  }
}
```

**QR Code Properties:**
- `size`: Number - Size of the QR code in pixels
- `content`: String - Data to encode in the QR code
- `level`: String - Error correction level
  - `"L"` = Low (~7% correction)
  - `"M"` = Medium (~15% correction)
  - `"Q"` = Quartile (~25% correction)
  - `"H"` = High (~30% correction)

---

#### 4. Jump Line (Blank Lines)

Adds empty space/blank lines.

```json
{
  "line": {
    "jump": 2
  }
}
```

The number indicates how many blank lines to insert.

---

#### 5. Two-Column Layout

Creates a row with two columns (useful for label-value pairs).

```json
{
  "line": {
    "column": [
      {
        "row": {
          "customization": {
            "font_size": 12,
            "alignment": 0,
            "font_style": {
              "bold": false,
              "italic": false
            }
          },
          "content": "Total",
          "size": null
        }
      },
      {
        "row": {
          "customization": {
            "font_size": 12,
            "alignment": 2,
            "font_style": {
              "bold": false,
              "italic": false
            }
          },
          "content": "47,80",
          "size": 10
        }
      }
    ]
  }
}
```

**Column Properties:**
- Each column is a `row` object with `customization` and `content`
- `size`: Number or null - Column width percentage (if specified)

---

#### 6. Table Layout with Headers and Items

Creates a table structure with headers and multiple rows of data.

```json
{
  "line": {
    "column": [
      {
        "header": [
          {
            "row": {
              "customization": {
                "font_size": 12,
                "alignment": 0,
                "font_style": {
                  "bold": true,
                  "italic": false
                }
              },
              "content": "DESCRIPTION",
              "size": 50
            }
          },
          {
            "row": {
              "customization": {
                "font_size": 12,
                "alignment": 2,
                "font_style": {
                  "bold": true,
                  "italic": false
                }
              },
              "content": "QTY",
              "size": 10
            }
          },
          {
            "row": {
              "customization": {
                "font_size": 12,
                "alignment": 2,
                "font_style": {
                  "bold": true,
                  "italic": false
                }
              },
              "content": "PRICE",
              "size": 20
            }
          },
          {
            "row": {
              "customization": {
                "font_size": 12,
                "alignment": 2,
                "font_style": {
                  "bold": true,
                  "italic": false
                }
              },
              "content": "TOTAL",
              "size": 20
            }
          }
        ],
        "items": [
          [
            {
              "row": {
                "customization": {
                  "font_size": 12,
                  "alignment": 0,
                  "font_style": {
                    "bold": false,
                    "italic": false
                  }
                },
                "content": "COLORADO RIBEIRAO 600ML LAGER",
                "size": null
              }
            },
            {
              "row": {
                "customization": {
                  "font_size": 12,
                  "alignment": 2,
                  "font_style": {
                    "bold": false,
                    "italic": false
                  }
                },
                "content": "1",
                "size": null
              }
            },
            {
              "row": {
                "customization": {
                  "font_size": 12,
                  "alignment": 2,
                  "font_style": {
                    "bold": false,
                    "italic": false
                  }
                },
                "content": "29,90",
                "size": null
              }
            },
            {
              "row": {
                "customization": {
                  "font_size": 12,
                  "alignment": 2,
                  "font_style": {
                    "bold": false,
                    "italic": false
                  }
                },
                "content": "29,90",
                "size": null
              }
            }
          ]
        ]
      }
    ]
  }
}
```

**Table Structure:**
- `header`: Array of row objects defining the table header columns
- `items`: Array of arrays, where each inner array represents a table row with its columns
- Each column's `size` property controls the relative width (percentage)

---

## Complete Example

Here's a complete receipt example demonstrating all features:

```dart
import 'package:flutter/material.dart';
import 'package:printer_gateway/printer_gateway.dart';
import 'dart:convert';

const String receiptJson = '''
[
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": true,
          "italic": false
        },
        "font_size": 18,
        "alignment": 1
      },
      "content": "MY HEADER"
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 1
      },
      "content": "xxxxxxxx"
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 1
      },
      "content": "33, Street"
    }
  },
  {
    "line": {
      "divider": true
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": true,
          "italic": false
        },
        "font_size": 12,
        "alignment": 1
      },
      "content": "Electronic Invoice - SAT"
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 0
      },
      "content": "CPF/CNPJ: "
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 0
      },
      "content": "Invoice: 005076"
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 0
      },
      "content": "Date: 2025-08-12 08:40:26"
    }
  },
  {
    "line": {
      "divider": true
    }
  },
  {
    "line": {
      "column": [
        {
          "header": [
            {
              "row": {
                "customization": {
                  "font_size": 12,
                  "alignment": 0,
                  "font_style": {
                    "bold": true,
                    "italic": false
                  }
                },
                "content": "DESCRIPTION",
                "size": 50
              }
            },
            {
              "row": {
                "customization": {
                  "font_size": 12,
                  "alignment": 2,
                  "font_style": {
                    "bold": true,
                    "italic": false
                  }
                },
                "content": "QTY",
                "size": 10
              }
            },
            {
              "row": {
                "customization": {
                  "font_size": 12,
                  "alignment": 2,
                  "font_style": {
                    "bold": true,
                    "italic": false
                  }
                },
                "content": "PRICE",
                "size": 20
              }
            },
            {
              "row": {
                "customization": {
                  "font_size": 12,
                  "alignment": 2,
                  "font_style": {
                    "bold": true,
                    "italic": false
                  }
                },
                "content": "TOTAL",
                "size": 20
              }
            }
          ],
          "items": [
            [
              {
                "row": {
                  "customization": {
                    "font_size": 12,
                    "alignment": 0,
                    "font_style": {
                      "bold": false,
                      "italic": false
                    }
                  },
                  "content": "COLORADO RIBEIRAO 600ML LAGER",
                  "size": null
                }
              },
              {
                "row": {
                  "customization": {
                    "font_size": 12,
                    "alignment": 2,
                    "font_style": {
                      "bold": false,
                      "italic": false
                    }
                  },
                  "content": "1",
                  "size": null
                }
              },
              {
                "row": {
                  "customization": {
                    "font_size": 12,
                    "alignment": 2,
                    "font_style": {
                      "bold": false,
                      "italic": false
                    }
                  },
                  "content": "29,90",
                  "size": null
                }
              },
              {
                "row": {
                  "customization": {
                    "font_size": 12,
                    "alignment": 2,
                    "font_style": {
                      "bold": false,
                      "italic": false
                    }
                  },
                  "content": "29,90",
                  "size": null
                }
              }
            ],
            [
              {
                "row": {
                  "customization": {
                    "font_size": 12,
                    "alignment": 0,
                    "font_style": {
                      "bold": false,
                      "italic": false
                    }
                  },
                  "content": "BECKS 330ML",
                  "size": null
                }
              },
              {
                "row": {
                  "customization": {
                    "font_size": 12,
                    "alignment": 2,
                    "font_style": {
                      "bold": false,
                      "italic": false
                    }
                  },
                  "content": "1",
                  "size": null
                }
              },
              {
                "row": {
                  "customization": {
                    "font_size": 12,
                    "alignment": 2,
                    "font_style": {
                      "bold": false,
                      "italic": false
                    }
                  },
                  "content": "17,90",
                  "size": null
                }
              },
              {
                "row": {
                  "customization": {
                    "font_size": 12,
                    "alignment": 2,
                    "font_style": {
                      "bold": false,
                      "italic": false
                    }
                  },
                  "content": "17,90",
                  "size": null
                }
              }
            ]
          ]
        }
      ]
    }
  },
  {
    "line": {
      "divider": true
    }
  },
  {
    "line": {
      "column": [
        {
          "row": {
            "customization": {
              "font_size": 12,
              "alignment": 0,
              "font_style": {
                "bold": false,
                "italic": false
              }
            },
            "content": "QTY of items",
            "size": null
          }
        },
        {
          "row": {
            "customization": {
              "font_size": 12,
              "alignment": 2,
              "font_style": {
                "bold": false,
                "italic": false
              }
            },
            "content": "2",
            "size": null
          }
        }
      ]
    }
  },
  {
    "line": {
      "column": [
        {
          "row": {
            "customization": {
              "font_size": 10,
              "alignment": 0,
              "font_style": {
                "bold": false,
                "italic": false
              }
            },
            "content": "Total",
            "size": null
          }
        },
        {
          "row": {
            "customization": {
              "font_size": 12,
              "alignment": 2,
              "font_style": {
                "bold": false,
                "italic": false
              }
            },
            "content": "47,80",
            "size": 10
          }
        }
      ]
    }
  },
  {
    "line": {
      "divider": true
    }
  },
  {
    "line": {
      "column": [
        {
          "row": {
            "customization": {
              "font_size": 10,
              "alignment": 0,
              "font_style": {
                "bold": true,
                "italic": false
              }
            },
            "content": "Payment methods",
            "size": null
          }
        },
        {
          "row": {
            "customization": {
              "font_size": 12,
              "alignment": 2,
              "font_style": {
                "bold": true,
                "italic": false
              }
            },
            "content": "Amount paid",
            "size": 10
          }
        }
      ]
    }
  },
  {
    "line": {
      "column": [
        {
          "row": {
            "customization": {
              "font_size": 10,
              "alignment": 0,
              "font_style": {
                "bold": false,
                "italic": false
              }
            },
            "content": "Cash",
            "size": null
          }
        },
        {
          "row": {
            "customization": {
              "font_size": 12,
              "alignment": 2,
              "font_style": {
                "bold": false,
                "italic": false
              }
            },
            "content": "54,01",
            "size": 10
          }
        }
      ]
    }
  },
  {
    "line": {
      "divider": true
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 1
      },
      "content": "INVOICE ACCESS KEY"
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 1
      },
      "content": "4345 0861 555 0800 0141 988 0015 765 0507 6936 6186"
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 1
      },
      "content": "Access the invoice at"
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 12,
        "alignment": 1
      },
      "content": "http://bit.ly/1LGaqOL"
    }
  },
  {
    "line": {
      "qrcode": {
        "size": 150,
        "content": "http://bit.ly/1LGaqOL|4232344234234234",
        "level": "L"
      }
    }
  },
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": false,
          "italic": false
        },
        "font_size": 10,
        "alignment": 1
      },
      "content": "Table: 555 - Service charge payment is optional"
    }
  }
]
''';

class ReceiptExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final printerGateway = PrinterGateway(jsonData: receiptJson);
    
    return Scaffold(
      appBar: AppBar(title: Text('Receipt Example')),
      body: SingleChildScrollView(
        child: Center(
          child: printerGateway.toWidget(
            maxWidth: 576,
            margin: 16,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Generate and print
          final imageBytes = await printerGateway.toImage(context);
          // Save or send to printer
        },
        child: Icon(Icons.print),
      ),
    );
  }
}
```

## Advanced Usage

### Adding Header and Footer Images

```dart
import 'package:flutter/services.dart';

// Load images from assets
final headerBytes = await rootBundle.load('assets/logo.png');
final footerBytes = await rootBundle.load('assets/footer.png');

final printerGateway = PrinterGateway(
  jsonData: receiptJson,
  imageHeader: headerBytes.buffer.asUint8List(),
  imageFooter: footerBytes.buffer.asUint8List(),
);

// Or add them later
printerGateway.addHeaderImage(headerBytes.buffer.asUint8List());
printerGateway.addFooterImage(footerBytes.buffer.asUint8List());
```

### Displaying Sensitive Information

When dealing with sensitive data like credit card numbers, passwords, or personal identification, use the `sensive_content` field to automatically obscure the sensitive parts:

```dart
const String receiptWithSensitiveData = '''
[
  {
    "line": {
      "customization": {
        "font_style": {
          "bold": true,
          "italic": false
        },
        "font_size": 12,
        "alignment": 0
      },
      "content": "Credit Card: ",
      "sensive_content": "4532123456789012"
    }
  },
  {
    "line": {
      "customization": {
        "font_size": 12,
        "alignment": 0,
        "font_style": {
          "bold": false,
          "italic": false
        }
      },
      "content": "Customer ID: ",
      "sensive_content": "ABC123XYZ789"
    }
  },
  {
    "line": {
      "customization": {
        "font_size": 12,
        "alignment": 0,
        "font_style": {
          "bold": false,
          "italic": false
        }
      },
      "content": "PIN: ",
      "sensive_content": "1234"
    }
  }
]
''';

// Output will be:
// Credit Card:  453**********12
// Customer ID:  ABC******89
// PIN:  1*34
```

### Using Reverse Text (White on Black)

Create emphasized sections with reversed colors:

```json
{
  "line": {
    "customization": {
      "font_style": {
        "bold": true,
        "italic": false
      },
      "font_size": 14,
      "alignment": 1,
      "reverse": true
    },
    "content": "IMPORTANT NOTICE"
  }
}
```

### Dynamic Data Updates

```dart
final printerGateway = PrinterGateway();

// Update data dynamically
printerGateway.addData(newJsonString);

// Render updated content
Widget updatedWidget = printerGateway.toWidget();
```

### Printing to Physical Printers

```dart
// For ESC/POS printers
final images = await printerGateway.toEscPosPrinter(
  context,
  maxWidth: 384, // 58mm paper
  maxHeight: 2000,
);

// Use with your printer library
for (var image in images) {
  await yourEscPosPrinter.printRaster(image);
}

// For POS printers (Uint8List)
final parts = await printerGateway.toPosPrinter(
  context,
  maxWidth: 576, // 80mm paper
);

for (var part in parts) {
  await yourPosPrinter.printImageData(part);
}
```

## JSON Schema Quick Reference

```json
{
  "line": {
    // TEXT LINE
    "customization": {
      "font_style": { "bold": true, "italic": false },
      "font_size": 12,
      "alignment": 0,  // 0=left, 1=center, 2=right, 3=justify
      "reverse": true,  // Optional: white text on black background
      "font_name": "CustomFont"  // Optional: custom font family
    },
    "content": "Text here",
    "sensive_content": "1234567890",  // Optional: auto-obscured to " 123*****90"
    
    // OR DIVIDER
    "divider": true,
    
    // OR QR CODE
    "qrcode": {
      "size": 150,
      "content": "QR data",
      "level": "L"  // L, M, Q, or H
    },
    
    // OR JUMP LINES
    "jump": 2,
    
    // OR COLUMNS (simple two-column)
    "column": [
      { "row": { "customization": {...}, "content": "Left", "size": null } },
      { "row": { "customization": {...}, "content": "Right", "size": 10 } }
    ],
    
    // OR TABLE (with header and items)
    "column": [
      {
        "header": [
          { "row": { "customization": {...}, "content": "Col1", "size": 50 } }
        ],
        "items": [
          [
            { "row": { "customization": {...}, "content": "Row1Col1", "size": null } }
          ]
        ]
      }
    ]
  }
}
```

## Tips and Best Practices

1. **Width Settings**: 
   - 58mm paper: `maxWidth: 384`
   - 80mm paper: `maxWidth: 576`

2. **Image Quality**: Use `fixedRatio: 2.0` or higher for better quality images when printing

3. **Long Receipts**: The package automatically splits long receipts when using `toPosPrinter()` or `toEscPosPrinter()`

4. **Column Sizing**: When using tables, specify `size` in header rows to control column widths (percentage of total width)

5. **QR Codes**: Use error correction level "L" or "M" for most cases. Higher levels ("Q", "H") are for environments with potential damage

6. **Testing**: Use `toWidget()` first to preview your receipt layout before printing

## Dependencies

This package depends on:
- `flutter`: SDK
- `image`: ^4.2.0
- `pretty_qr_code`: ^3.3.0
- `screenshot`: ^3.0.0

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created and maintained by [brasizza](https://github.com/brasizza)

## Issues and Feedback

For issues, feature requests, or questions, please file an issue on the [GitHub repository](https://github.com/brasizza/printer_gateway/issues).

# Adidas Sales Performance Dashboard (Power BI)
This Power BI dashboard analyzes Adidas sales data from 2020–2021, offering insight into product performance, retailer trends, and regional demand. Built with a star schema model and SQL-transformed data, the dashboard was created to support strategic decisions in product development, retail partnerships, and market expansion.

🔗 [Click here to view the live dashboard](https://github.com/Edumais37/powerbi-adidas-sales/blob/main/report/Adidas_Sales_Dashboard.pbix)  

📄 [Download PDF version](https://github.com/Edumais37/powerbi-adidas-sales/blob/main/report/Adidas_Sales_Dashboard_PDF.pdf)



<br>

## Dashboard Preview

![Adidas Dashboard Preview](https://github.com/Edumais37/powerbi-adidas-sales/blob/main/report/Adidas_Dash_Page1.png) 


<br>

## Folder Structure

```
powerbi-adidas-sales/
|-- data/
    |-- Adidas US Sales Datasets.xlsx         
    |-- Adidas US Sales Datasets 2.csv       # Input dataset (CSV format)
|-- sql/
    |-- Adidas_Sales_Script2.sql             # Format and model data
    |                                        # Calculate metrics, create star schema for use in Power BI
|-- report/
    |-- Adidas_Sales_Dashboard.pbix          # Power BI project file
|-- README.md                                # Overview, key insights and analysis
```
<br>

## Tools Used
Power BI Desktop – Dashboard creation and interactivity

MySQL Workbench – SQL data cleaning and modeling

Excel – Preliminary inspection and formatting

<br> 

## Project Features
Star Schema Data Model with fact and dimension tables for performance and clarity

Interactive Visuals & Slicers to toggle by region, city, date, and margin tier

Bookmark Navigation for smooth chart switching (e.g., Region vs. City view)

Clean Layout with supporting KPI cards, matrix views, and contextual labels

Published Report & PDF Export

<br>

## Key Insights
### Product Performance
- Footwear outsells apparel 2-to-1 in total sales and dominates in both high and medium margins.

- Men’s street footwear and women’s apparel are top performers by sales, but succeed with very different margin strategies.

- Medium-margin products drive the highest operating profit due to strong sales volume and decent per-unit profitability.

### Retailer Behavior
- West Gear and Footlocker led in total sales, favoring low-margin, high-volume products.

- Sports Direct emerged as the top seller of high-margin products, particularly in Southern cities.

- Inconsistencies in 2020 retail data suggest onboarding new partners or temporary contract breaks; 2021 shows full retailer engagement across all brands.

 ### Regional Highlights
- The South region sold the most high-margin products despite having lower total sales overall, suggesting strategic potential.

- New York City and San Francisco were the top-grossing cities; however, NYC recorded no sales in 2021, raising questions about distribution.

- Seasonal trends appeared around back-to-school and holiday periods, varying by retailer and product.

### Margin Dynamics
- Average profit per unit increases with margin tier: Low (26%) < Medium (31%) < High (43%).

- Medium-margin footwear offers the best balance of sales volume and profitability.

- Apparel dominates in high-margin profits, while footwear leads in both low and medium tiers.

### Sales Channels
- Data was collected evenly from all sales channels for consistency purposes

<br>

## Recommended Actions
- Expand high-margin product distribution in the South, leveraging strong Sports Direct performance.

- Investigate West Gear’s success with low-margin volume — consider scaling to other markets.

- Capitalize on medium-margin products, especially footwear, to maximize profit at scale.

- Explore product event tie-ins to boost less demanded lines during seasonal spikes.

- Review 2021 NYC sales void — logistical issue or market shift?

<br>

## Additional Views

![Toggled Charts Preview](https://github.com/Edumais37/powerbi-adidas-sales/blob/main/report/Adidas_Dash_Page2.png) 
## View the Dashboard
Live Report (Power BI Service)

PDF Export (Static Overview)

<br>

**To explore the dashboard interactively:**

Download Power BI Desktop

Clone or download this repo.

Open Adidas_Sales_Dashboard.pbix in Power BI

<br>

## Contact
**Author:** Elliot Dumais

**LinkedIn:** www.linkedin.com/in/elliot-dumais-aa0a55358

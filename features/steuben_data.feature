Feature: Data Unification

    We take data from many tabs and mash them all into one tab

    Scenario: Stitching tabs together
    
    Given we start from the webpage where the data is kept updated
    And we have downloaded a spreadsheet full of many tabs of mostly similar data
    
    When the site name is located on a numbered tab
    And the numbered tabs all contain different variables in each row
    And the dates are column headers
    And the data is gathered from the many tabs into one list of records
    And the tabs labeled "Key" and "Quad" can be ignored
    
    Then each record in the list is written into the output spreadsheet
    And each column represents a variable, an observation date, or the site name
    And each row represents an observation of one or more of the variables
    And the site name is added to the end of each row in an additional column

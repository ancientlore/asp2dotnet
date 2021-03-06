<%

Class cAuthor

'Private, class member variable
Private m_ID
Private m_FirstName
Private m_LastName
Private m_Title
private m_Books

'Read the current ID value
Public Property Get ID()
    ID = m_ID
End Property
'store a new ID value
Public Property Let ID(p_Data)
    m_ID = p_Data
End Property

'Read the current FirstName value
Public Property Get FirstName()
    FirstName = m_FirstName
End Property
'store a new ISBN value
Public Property Let FirstName(p_Data)
    m_FirstName = p_Data
End Property

'Read the current LastName value
Public Property Get LastName()
    LastName = m_LastName
End Property
'store a new LastName value
Public Property Let LastName(p_Data)
    m_LastName = p_Data
End Property

'Read the current Title value
Public Property Get Title()
    Title = m_Title
End Property
'store a new Title value
Public Property Let Title(p_Data)
    m_Title = p_Data
End Property

Public Property Get Books()
    if not isobject(m_Books) then
		Dim Library
        set Library = New cLibrary
        call Library.GetBooksByAuthorID(Me.ID)
        set m_books = Library.Books
        Set Library = nothing
    end if
    Set Books = m_Books
End Property

'#############  Public Functions, accessible to the web pages ##############
    'Loads this object's values by loading a record based on the given ID
    Public Function LoadFromId(p_Id)
        dim strSQL, MyID
        MyID = clng(p_Id)
        strSQL = "SELECT Author.lngAuthorID, Author.strFirstName, Author.strLastName, Author.strTitle "
        strSQL = strSQL & " FROM Author "
        strSQL = strSQL &   " WHERE (lngAuthorID = " & MyID & ") "
        LoadFromId = LoadData (strSQL)
    End Function

    'Loads this object's values by loading a record based on the given ID
    Public Function LoadFromLastName(p_Data)
        dim strSQL
        strSQL = "SELECT Author.lngAuthorID, Author.strFirstName, Author.strLastName, Author.strTitle "
        strSQL = strSQL & " FROM Author "
        strSQL = strSQL &   " WHERE (LastName = '" & SingleQuotes(p_Data) & "') "
        LoadFromLastName = LoadData (strSQL)
    End Function

    public Function Store()
    Dim strSQL
        'If the book has an existing (Autogenerated!) ID, then run an insert
        if Me.ID < 1 then
            Dim ThisRecordID, arr1, arr2
            arr1 = Array("strFirstName", "strLastName", "strTitle")
            arr2 = Array(Me.FirstName,   Me.LastName,    Me.Title)
            Me.ID = InsertRecord("Author", "lngAuthorID", arr1, arr2)
        'Otherwise run an update
        else
            strSQL = strSQL & " UPDATE Author SET "
            strSQL = strSQL & " strFirstName = '" & SingleQuotes(Me.FirstName) & "',"
            strSQL = strSQL & " strLastName = '" & SingleQuotes(Me.LastName) & "',"
            strSQL = strSQL & " strTitle = '" & SingleQuotes(Me.Title) &  "'"
            strSQL = strSQL & " where lngAuthorID = " & Me.ID
            RunSQL strSQL
        End if
        Store =  Me.ID
    End Function

    Public Function Delete
		Dim strSQL
        strSQL = "DELETE * FROM author WHERE lngAuthorID = " & Me.ID
        RunSQL strSQL
    End Function

    Public Sub AddBook(p_Book)
        dim Library
        set Library = new cLibrary
        if isObject(p_Book) Then
            Library.AssociateAuthorWithBook Me.ID, p_Book.ID
        else
            Library.AssociateAuthorWithBook Me.ID, p_Book
        End if
        Set Library = Nothing
    End Sub

'#############  Private Functions                           ##############

    'Takes a recordset
    'Fills the object's properties using the recordset
    Private Function FillFromRS(p_RS)
        select case p_RS.recordcount
            case 1
                Me.ID                 = p_RS.fields("lngAuthorID").Value
                Me.FirstName          = p_RS.fields("strFirstName").Value
                Me.LastName           = p_RS.fields("strLastName").Value
                Me.Title              = p_RS.fields("strTitle").Value
                FillFromRS            = Me.ID
            case -1, 0
                'err.raise 2, "Item was not found"
            case else
                err.raise 3, "Item was not unique"
        end select
    End Function

    Private Function LoadData(p_strSQL)
        dim rs
        set rs = LoadRSFromDB(p_strSQL)
        LoadData = FillFromRS(rs)
        rs. close
        set rs = nothing
    End Function
End Class

%>
sub GetSecurityGroups { # Creates/fills a hash $SecurityGroups{$GroupID}{} with all authors
  my ($GroupID,$Name,$Description,$Timestamp);
  my $group_list  = $dbh -> prepare(
     "select GroupID,Name,Description,Timestamp from SecurityGroup"); 
  $group_list -> execute;
  $group_list -> bind_columns(undef, \($GroupID,$Name,$Description,$Timestamp));
  %SecurityGroups = ();
  while ($group_list -> fetch) {
    $SecurityGroups{$GroupID}{GROUPID}     = $GroupID;
    $SecurityGroups{$GroupID}{NAME}        = $Name;
    $SecurityGroups{$GroupID}{DESCRIPTION} = $Description;
    $SecurityGroups{$GroupID}{TIMESTAMP}   = $Timestamp;
    $SecurityIDs{$Name} = $GroupID;
  }
  
  my ($HierarchyID,$ChildID,$ParentID);
  my $hierarchy_list  = $dbh -> prepare(
     "select HierarchyID,ChildID,ParentID,Timestamp from GroupHierarchy"); 
  $hierarchy_list -> execute;
  $hierarchy_list -> bind_columns(undef, \($HierarchyID,$ChildID,$ParentID,$Timestamp));
  %GroupsHierarchy = ();
  while ($hierarchy_list -> fetch) {
    $GroupsHierarchy{$HierarchyID}{HIERARCHY} = $HierarchyID;
    $GroupsHierarchy{$HierarchyID}{CHILD}     = $ChildID;
    $GroupsHierarchy{$HierarchyID}{PARENT}    = $ParentID;
    $GroupsHierarchy{$HierarchyID}{TIMESTAMP} = $Timestamp;
  }
}

sub GetRevisionSecurityGroups {
  my ($DocRevID) = @_;
  
  if ($RevisionSecurities{$DocRevID}{DocRevID}) {
    return \@{$RevisionSecurities{$DocRevID}{GROUPS}};
  }
    
  my @groups = ();
  my ($RevTopicID,$GroupID);
  my $group_list = $dbh->prepare(
    "select RevSecurityID,GroupID from RevisionSecurity where DocRevID=?");
  $group_list -> execute($DocRevID);
  $group_list -> bind_columns(undef, \($RevTopicID,$GroupID));
  while ($group_list -> fetch) {
    push @groups,$GroupID;
  }
  $RevisionSecurities{$DocRevID}{DocRevID} = $DocRevID;
  $RevisionSecurities{$DocRevID}{GROUPS}   = [@groups];
  return \@{$RevisionSecurities{$DocRevID}{GROUPS}};
}


1;

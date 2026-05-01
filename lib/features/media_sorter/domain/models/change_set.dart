enum DataBaseOperationType { insert, update, delete, deleteWhere }

/*Contains a companion wrapper and the type of db operation
*/
abstract class SyncRequest {}

abstract class SyncRequestWithoutHist extends SyncRequest {}

/*
Contains a companion wrapper for history that SyncRequest does not have
*/
abstract class SyncRequestWithHist extends SyncRequest {}

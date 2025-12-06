// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCellModelCollection on Isar {
  IsarCollection<CellModel> get cellModels => this.collection();
}

const CellModelSchema = CollectionSchema(
  name: r'CellModel',
  id: -2338816858777947365,
  properties: {
    r'col': PropertySchema(
      id: 0,
      name: r'col',
      type: IsarType.long,
    ),
    r'row': PropertySchema(
      id: 1,
      name: r'row',
      type: IsarType.long,
    ),
    r'value': PropertySchema(
      id: 2,
      name: r'value',
      type: IsarType.string,
    )
  },
  estimateSize: _cellModelEstimateSize,
  serialize: _cellModelSerialize,
  deserialize: _cellModelDeserialize,
  deserializeProp: _cellModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'row_col': IndexSchema(
      id: -767563199783380316,
      name: r'row_col',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'row',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'col',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cellModelGetId,
  getLinks: _cellModelGetLinks,
  attach: _cellModelAttach,
  version: '3.1.0+1',
);

int _cellModelEstimateSize(
  CellModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.value.length * 3;
  return bytesCount;
}

void _cellModelSerialize(
  CellModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.col);
  writer.writeLong(offsets[1], object.row);
  writer.writeString(offsets[2], object.value);
}

CellModel _cellModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CellModel();
  object.col = reader.readLong(offsets[0]);
  object.id = id;
  object.row = reader.readLong(offsets[1]);
  object.value = reader.readString(offsets[2]);
  return object;
}

P _cellModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cellModelGetId(CellModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cellModelGetLinks(CellModel object) {
  return [];
}

void _cellModelAttach(IsarCollection<dynamic> col, Id id, CellModel object) {
  object.id = id;
}

extension CellModelQueryWhereSort
    on QueryBuilder<CellModel, CellModel, QWhere> {
  QueryBuilder<CellModel, CellModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhere> anyRowCol() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'row_col'),
      );
    });
  }
}

extension CellModelQueryWhere
    on QueryBuilder<CellModel, CellModel, QWhereClause> {
  QueryBuilder<CellModel, CellModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowEqualToAnyCol(
      int row) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'row_col',
        value: [row],
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowNotEqualToAnyCol(
      int row) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row_col',
              lower: [],
              upper: [row],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row_col',
              lower: [row],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row_col',
              lower: [row],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row_col',
              lower: [],
              upper: [row],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowGreaterThanAnyCol(
    int row, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row_col',
        lower: [row],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowLessThanAnyCol(
    int row, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row_col',
        lower: [],
        upper: [row],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowBetweenAnyCol(
    int lowerRow,
    int upperRow, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row_col',
        lower: [lowerRow],
        includeLower: includeLower,
        upper: [upperRow],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowColEqualTo(
      int row, int col) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'row_col',
        value: [row, col],
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowEqualToColNotEqualTo(
      int row, int col) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row_col',
              lower: [row],
              upper: [row, col],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row_col',
              lower: [row, col],
              includeLower: false,
              upper: [row],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row_col',
              lower: [row, col],
              includeLower: false,
              upper: [row],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row_col',
              lower: [row],
              upper: [row, col],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause>
      rowEqualToColGreaterThan(
    int row,
    int col, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row_col',
        lower: [row, col],
        includeLower: include,
        upper: [row],
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowEqualToColLessThan(
    int row,
    int col, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row_col',
        lower: [row],
        upper: [row, col],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterWhereClause> rowEqualToColBetween(
    int row,
    int lowerCol,
    int upperCol, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row_col',
        lower: [row, lowerCol],
        includeLower: includeLower,
        upper: [row, upperCol],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CellModelQueryFilter
    on QueryBuilder<CellModel, CellModel, QFilterCondition> {
  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> colEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'col',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> colGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'col',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> colLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'col',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> colBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'col',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> rowEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> rowGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> rowLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> rowBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'row',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'value',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'value',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: '',
      ));
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterFilterCondition> valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'value',
        value: '',
      ));
    });
  }
}

extension CellModelQueryObject
    on QueryBuilder<CellModel, CellModel, QFilterCondition> {}

extension CellModelQueryLinks
    on QueryBuilder<CellModel, CellModel, QFilterCondition> {}

extension CellModelQuerySortBy on QueryBuilder<CellModel, CellModel, QSortBy> {
  QueryBuilder<CellModel, CellModel, QAfterSortBy> sortByCol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'col', Sort.asc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> sortByColDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'col', Sort.desc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> sortByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.asc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> sortByRowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.desc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension CellModelQuerySortThenBy
    on QueryBuilder<CellModel, CellModel, QSortThenBy> {
  QueryBuilder<CellModel, CellModel, QAfterSortBy> thenByCol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'col', Sort.asc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> thenByColDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'col', Sort.desc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> thenByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.asc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> thenByRowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.desc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<CellModel, CellModel, QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension CellModelQueryWhereDistinct
    on QueryBuilder<CellModel, CellModel, QDistinct> {
  QueryBuilder<CellModel, CellModel, QDistinct> distinctByCol() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'col');
    });
  }

  QueryBuilder<CellModel, CellModel, QDistinct> distinctByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'row');
    });
  }

  QueryBuilder<CellModel, CellModel, QDistinct> distinctByValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value', caseSensitive: caseSensitive);
    });
  }
}

extension CellModelQueryProperty
    on QueryBuilder<CellModel, CellModel, QQueryProperty> {
  QueryBuilder<CellModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CellModel, int, QQueryOperations> colProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'col');
    });
  }

  QueryBuilder<CellModel, int, QQueryOperations> rowProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'row');
    });
  }

  QueryBuilder<CellModel, String, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}

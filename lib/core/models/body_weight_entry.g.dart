// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_weight_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetBodyWeightEntryCollection on Isar {
  IsarCollection<BodyWeightEntry> get bodyWeightEntrys => this.collection();
}

const BodyWeightEntrySchema = CollectionSchema(
  name: r'BodyWeightEntry',
  id: 5925091869824956701,
  properties: {
    r'date': PropertySchema(id: 0, name: r'date', type: IsarType.dateTime),
    r'weightKg': PropertySchema(
      id: 1,
      name: r'weightKg',
      type: IsarType.double,
    ),
  },

  estimateSize: _bodyWeightEntryEstimateSize,
  serialize: _bodyWeightEntrySerialize,
  deserialize: _bodyWeightEntryDeserialize,
  deserializeProp: _bodyWeightEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _bodyWeightEntryGetId,
  getLinks: _bodyWeightEntryGetLinks,
  attach: _bodyWeightEntryAttach,
  version: '3.4.1',
);

int _bodyWeightEntryEstimateSize(
  BodyWeightEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _bodyWeightEntrySerialize(
  BodyWeightEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeDouble(offsets[1], object.weightKg);
}

BodyWeightEntry _bodyWeightEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BodyWeightEntry(
    date: reader.readDateTime(offsets[0]),
    id: id,
    weightKg: reader.readDouble(offsets[1]),
  );
  return object;
}

P _bodyWeightEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bodyWeightEntryGetId(BodyWeightEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bodyWeightEntryGetLinks(BodyWeightEntry object) {
  return [];
}

void _bodyWeightEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  BodyWeightEntry object,
) {
  object.id = id;
}

extension BodyWeightEntryQueryWhereSort
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QWhere> {
  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BodyWeightEntryQueryWhere
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QWhereClause> {
  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BodyWeightEntryQueryFilter
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QFilterCondition> {
  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  weightKgEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weightKg',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  weightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weightKg',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  weightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weightKg',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterFilterCondition>
  weightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weightKg',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension BodyWeightEntryQueryObject
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QFilterCondition> {}

extension BodyWeightEntryQueryLinks
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QFilterCondition> {}

extension BodyWeightEntryQuerySortBy
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QSortBy> {
  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy>
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy>
  sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy>
  sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension BodyWeightEntryQuerySortThenBy
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QSortThenBy> {
  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy>
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy>
  thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QAfterSortBy>
  thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension BodyWeightEntryQueryWhereDistinct
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QDistinct> {
  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<BodyWeightEntry, BodyWeightEntry, QDistinct>
  distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension BodyWeightEntryQueryProperty
    on QueryBuilder<BodyWeightEntry, BodyWeightEntry, QQueryProperty> {
  QueryBuilder<BodyWeightEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BodyWeightEntry, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<BodyWeightEntry, double, QQueryOperations> weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}

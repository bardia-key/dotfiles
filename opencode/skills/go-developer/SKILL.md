---
name: go-developer
description: Go development best practices and patterns
license: MIT
compatibility: opencode
metadata:
  audience: go-developers
  workflow: development
---

## What I do

I guide Go development with idiomatic patterns, enforcing clean architecture, testability, and conventional Go style.

## When to use me

Use this skill when:
- Working in any Go project (has `go.mod`) or editing `.go` files
- Writing new packages, services, or repositories
- Writing or reviewing tests
- Refactoring existing Go code

---

## Repository Pattern

Always use the clean repository pattern for data access:
- Define the repository **interface** in the domain/consumer package
- Provide a concrete struct implementation
- Wire dependencies through a constructor

```go
// domain/user.go - interface lives where it is consumed
type UserRepository interface {
    FindByID(ctx context.Context, id int) (*User, error)
    Save(ctx context.Context, u *User) error
}

// mysql/user_repository.go - concrete implementation
type userRepository struct {
    db *sql.DB
}

func NewUserRepository(db *sql.DB) domain.UserRepository {
    return &userRepository{db: db}
}

func (r *userRepository) FindByID(ctx context.Context, id int) (*domain.User, error) {
    // ...
}
```

---

## Test Structure: t.Run for Edge Cases

Organize all edge cases for a function under `t.Run` subtests inside the parent `TestX` function. Pair with a table-driven struct slice for clarity and scalability.

```go
func TestFindByID(t *testing.T) {
    tests := []struct {
        name    string
        id      int
        want    *User
        wantErr bool
    }{
        {
            name: "returns user when found",
            id:   1,
            want: &User{ID: 1, Name: "Alice"},
        },
        {
            name:    "returns error when not found",
            id:      999,
            wantErr: true,
        },
        {
            name:    "returns error on invalid id",
            id:      -1,
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := repo.FindByID(context.Background(), tt.id)
            if (err != nil) != tt.wantErr {
                t.Fatalf("wantErr=%v, got err=%v", tt.wantErr, err)
            }
            if !tt.wantErr && !reflect.DeepEqual(got, tt.want) {
                t.Errorf("want %+v, got %+v", tt.want, got)
            }
        })
    }
}
```

---

## Error Handling

Always return errors explicitly — never swallow them. Wrap errors with context using `fmt.Errorf` and the `%w` verb so callers can use `errors.Is` / `errors.As`.

```go
// Good
func (r *userRepository) FindByID(ctx context.Context, id int) (*User, error) {
    u, err := r.db.QueryRowContext(ctx, query, id).Scan(...)
    if err != nil {
        return nil, fmt.Errorf("userRepository.FindByID id=%d: %w", id, err)
    }
    return u, nil
}

// Bad - never do this
func (r *userRepository) FindByID(ctx context.Context, id int) *User {
    u, _ := r.db.QueryRowContext(ctx, query, id).Scan(...)
    return u
}
```

---

## Context Propagation

Pass `context.Context` as the **first parameter** to any function that performs I/O, network calls, database queries, or long-running work. Never store a context in a struct.

```go
// Good
func (s *UserService) GetUser(ctx context.Context, id int) (*User, error) {
    return s.repo.FindByID(ctx, id)
}

// Bad - context stored in struct
type UserService struct {
    ctx context.Context // never do this
    repo UserRepository
}
```

---

## Interfaces at the Consumer Side

Define interfaces in the package that **uses** them, not in the package that implements them. This keeps implementations decoupled and avoids import cycles.

```go
// service/user.go - consumer defines the interface it needs
package service

type userRepo interface {
    FindByID(ctx context.Context, id int) (*domain.User, error)
}

type UserService struct {
    repo userRepo
}
```

---

## Naming Conventions

- **Receiver names**: short (1-2 chars), consistent per type — `u *User`, `r *userRepository`
- **Acronyms**: all-caps — `HTTPClient`, `URLParser`, `UserID`, not `HttpClient`, `UrlParser`, `UserId`
- **Unexported by default**: only export what external packages need
- **Constructor prefix**: `New` — `NewUserService`, `NewUserRepository`
- **Error variables**: prefix with `Err` — `ErrNotFound`, `ErrInvalidID`

```go
type HTTPClient struct { ... }          // acronym all-caps
type userRepository struct { ... }      // unexported concrete type
var ErrNotFound = errors.New("not found")

func (r *userRepository) save(...) {}   // short receiver name
func NewUserRepository(...) UserRepository { ... }
```

---

## Mocking Strategy

Use interface-based mocks for testing. Prefer hand-written mocks for simple cases; use `testify/mock` for complex interaction verification.

```go
// Hand-written mock for simple cases
type mockUserRepo struct {
    findByIDFn func(ctx context.Context, id int) (*User, error)
}

func (m *mockUserRepo) FindByID(ctx context.Context, id int) (*User, error) {
    return m.findByIDFn(ctx, id)
}

// Usage in test
repo := &mockUserRepo{
    findByIDFn: func(ctx context.Context, id int) (*User, error) {
        return &User{ID: id, Name: "Alice"}, nil
    },
}
svc := NewUserService(repo)
```

---

## Struct Construction

Use a `Config` struct or option functions when a constructor takes more than 3 parameters. Avoid long positional argument lists.

```go
// Config struct approach
type ServerConfig struct {
    Host    string
    Port    int
    Timeout time.Duration
    Logger  *slog.Logger
}

func NewServer(cfg ServerConfig) *Server {
    return &Server{cfg: cfg}
}

// Option function approach
type Option func(*Server)

func WithTimeout(d time.Duration) Option {
    return func(s *Server) { s.timeout = d }
}

func NewServer(host string, port int, opts ...Option) *Server {
    s := &Server{host: host, port: port}
    for _, o := range opts {
        o(s)
    }
    return s
}
```

---

## Summary Checklist

Before submitting Go code, verify:

- [ ] Data access behind a repository interface
- [ ] Interface defined in consumer package
- [ ] All test edge cases use `t.Run` inside `TestX`
- [ ] Table-driven tests with a `tests []struct{...}` slice
- [ ] Errors wrapped with `fmt.Errorf("...: %w", err)`
- [ ] No swallowed errors (no bare `_` on error returns)
- [ ] `context.Context` is first param on I/O functions
- [ ] Receiver names are short and consistent
- [ ] Acronyms are all-caps
- [ ] Constructors use `Config` struct or option funcs when > 3 params
- [ ] Mocks are interface-based

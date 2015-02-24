#ifndef _REDBLACK_H_
#define _REDBLACK_H_

#include <iostream>
//#include <exception>
#include <assert.h>
#include <string>
using namespace std;

// http://stackoverflow.com/a/5590404/1062499
#include <sstream>
#define SSTR( x ) dynamic_cast< std::ostringstream & >(     \
        ( std::ostringstream() << std::dec << x ) ).str()

template <typename Type>
class Node
{
public:
    Node(Type val);
    virtual ~Node();

    Type value;
    Node *left;
    Node *right;
    Node *parent;
    bool red;
//private:
};

template <typename Type>
class RedBlackTreeIterator
{
public:
    RedBlackTreeIterator(Node<Type> *s);
    ~RedBlackTreeIterator();

    RedBlackTreeIterator<Type>& operator=(const RedBlackTreeIterator<Type>&);
    RedBlackTreeIterator<Type>& operator++();
    Node<Type>& operator*() const;
    bool operator==(const RedBlackTreeIterator<Type>&);
    bool operator!=(const RedBlackTreeIterator<Type>&);
private:
    Node<Type> *current;
};

template <typename Type, typename Comp = std::less< Type > >
class RedBlackTree
{
public:
    RedBlackTree();
    virtual ~RedBlackTree();

    void find(Type in_Value, Node<Type>* &out_pNode, int &dir);
    bool insert(Type value, Type* &out_pFoundValue);
    bool remove(Type value, Type &out_foundValue);

    RedBlackTreeIterator<Type> begin();
    RedBlackTreeIterator<Type> end();

#ifdef DEBUG
    string to_string();
#endif // DEBUG
private:
#ifdef DEBUG
    string _to_string(Node<Type> *node);
#endif // DEBUG
    void left_rotate(Node<Type> *node);
    void right_rotate(Node<Type> *node);

    Node<Type> *root;
    Comp comp;
};

// ======================================================================
//  NODE
// ======================================================================

template <typename Type>
Node<Type>::Node(Type val)
{
    this->value = val;
    this->left = 0;
    this->right = 0;
    this->parent = 0;
    this->red = true;
}

template <typename Type>
Node<Type>::~Node()
{
    if (this->left) delete this->left;
    if (this->right) delete this->right;
}


// ======================================================================
//  ITERATOR
// ======================================================================

template <typename Type>
RedBlackTreeIterator<Type>::RedBlackTreeIterator(Node<Type>*s)
{
    this->current = s;
}

template <typename Type>
RedBlackTreeIterator<Type>::~RedBlackTreeIterator()
{

}

template <typename Type>
RedBlackTreeIterator<Type>&
RedBlackTreeIterator<Type>::operator=(const RedBlackTreeIterator<Type> &i)
{
    this->current = i.current;
    return *this;
}

template <typename Type>
RedBlackTreeIterator<Type>&
RedBlackTreeIterator<Type>::operator++()
{
    if (!this->current)
        throw exception();

    if (this->current->right)
    {
        this->current = this->current->right;
        while (this->current->left)
            this->current = this->current->left;
        return *this;
    }
    if (this->current->parent)
    {
        if (this->current == this->current->parent->left)
        {
            this->current = this->current->parent;
            return *this;
        }
        else
        {
            while (this->current->parent)
            {
                if (this->current == this->current->parent->left)
                {
                    this->current = this->current->parent;
                    return *this;
                }
                this->current = this->current->parent;
            }
        }
    }
    // iterator is over
    this->current = 0;
    return *this;
}

template <typename Type>
Node<Type>&
RedBlackTreeIterator<Type>::operator*() const
{
    if (this->current)
    {
        return *(this->current);
    }
    else
        throw exception();
}

template <typename Type>
bool
RedBlackTreeIterator<Type>::operator==(const RedBlackTreeIterator<Type> &i)
{
    return (this->current == i.current);
}

template <typename Type>
bool
RedBlackTreeIterator<Type>::operator!=(const RedBlackTreeIterator<Type> &i)
{
    return (this->current != i.current);
}


// ======================================================================
//  TREE
// ======================================================================

template <typename Type, typename Comp>
RedBlackTree<Type, Comp>::RedBlackTree()
{
    this->root = 0;
}

template <typename Type, typename Comp>
RedBlackTree<Type, Comp>::~RedBlackTree()
{
    if (this->root) delete this->root;
}

/**
 * find
 *
 * \param in_Value <description>
 * \param out_pNode <description>
 * \param out_Dir <description>
 * \return <Comp>>
 */
template <typename Type, typename Comp>
void
RedBlackTree<Type, Comp>::find ( Type         in_Value,
                                 Node<Type>* &out_pNode,
                                 int         &out_Dir )
{
    out_pNode = this->root;
    while (out_pNode)
    {
        if (comp(in_Value, out_pNode->value))
        {
            if (out_pNode->left)
                out_pNode = out_pNode->left;
            else
            {
                out_Dir = -1;
                return;
            }
        }
        else if (comp(out_pNode->value, in_Value))
        {
            if (out_pNode->right)
                out_pNode = out_pNode->right;
            else
            {
                out_Dir = 1;
                return;
            }
        }
        else
        {
            out_Dir = 0;
            return;
        }
    }
}

/**
 * Inserts a new node with the given value into the tree.
 *
 * \param value the value to store
 * \return True if the tree is changed by the operation; false
 * otherwise (i.e., value was already contained in the tree).
 */
template <typename Type, typename Comp>
bool
RedBlackTree<Type, Comp>::insert(Type value, Type* &out_pFoundValue)
{
    Node<Type> *pNewNode = new Node<Type>(value);
    Node<Type> *current;
    int dir;
    find(value, current, dir);
    if (!current)
    {
        this->root = pNewNode;
        this->root->red = false;
        out_pFoundValue = &pNewNode->value;
        return true;
    }
    if (dir == 0)
    {
        // tree already contains the value, quit now
        delete pNewNode;
        out_pFoundValue = &current->value;
        return false;
    }
    out_pFoundValue = &pNewNode->value;
    // current is an internal node of the tree
    if (dir < 0)
    {
        current->left = pNewNode;
    }
    else
    {
        current->right = pNewNode;
    }
    pNewNode->parent = current;
    // now rearrange the tree on the inserted node
    current = pNewNode;
    Node<Type> *parent;
    Node<Type> *uncle;
    Node<Type> *grandparent;
    bool current_left;
    bool parent_left;
    while (1)
    {
        // get parent and uncle if possible
        parent = 0;
        uncle = 0;
        grandparent = 0;
        current_left = false;
        parent_left = false;
        if (current->parent)
        {
            parent = current->parent;
            current_left = (current == parent->left);
            if (parent->parent)
            {
                grandparent = parent->parent;
                parent_left = (parent == grandparent->left);
                uncle = (parent_left ? grandparent->right : grandparent->left);
            }
        }
        // case 1: current is the root
        // then make it black and quit
        if (!parent)
        {
            current->red = false;
            return true;
        }
        // case 2: parent is black
        // do nothing and quit
        if (!parent->red)
        {
            return true;
        }
        // case 3: parent and uncle are red
        // make both black, make grandparent red, set current to
        // grandparent and repeat
        if (parent->red && uncle && uncle->red)
        {
            parent->red = uncle->red = false;
            grandparent->red = true;
            current = grandparent;
            continue;
        }
        // case 4 and 5: parent is red, uncle is black
        if (parent->red && (!uncle || !uncle->red))
            break;
    }
    // cases 4 and 5 handled here
    // parent left:
    if (parent_left)
    {
        // case 4: current is right child
        // left rotate on parent, parent becomes current (we don't
        // need the old parent anymore)
        if (!current_left)
        {
            //cout << "case 4 left: left rotate" << endl;
            left_rotate(parent);
            parent = current;
            //cout << "tree: " << this->to_string() << endl;
        }
        // case 5: current is left child
        // right rotate grandparent, make grandparent red, parent black
        //cout << "case 5 right: left rotate" << endl;
        //cout << "tree: " << this->to_string() << endl;
        grandparent->red = true;
        parent->red = false;
        right_rotate(grandparent);
        //cout << "tree: " << this->to_string() << endl;
    }
    // parent right:
    else
    {
        // case 4: current is left child
        // right rotate on parent, parent becomes current (we don't
        // need the old parent anymore)
        if (current_left)
        {
            //cout << "case 4 right: right rotate" << endl;
            right_rotate(parent);
            parent = current;
            //cout << "tree: " << this->to_string() << endl;
        }
        // case 5: current is right child
        // left rotate grandparent, make grandparent red, parent black
        //cout << "case 5 right: left rotate" << endl;
        grandparent->red = true;
        parent->red = false;
        left_rotate(grandparent);
        //cout << "tree: " << this->to_string() << endl;
    }
    return true;
}

template <typename Type, typename Comp>
bool
RedBlackTree<Type, Comp>::remove(Type value, Type &out_foundValue)
{
    if (!this->root) return false;
    Node<Type> *foundNode;
    int dir;
    find(value, foundNode, dir);
    if (!foundNode) return false;
    // check if the find failed to find a matching node
    if (dir != 0) return false;
    // swap foundNode with a child that itself has maximally one child
    Node<Type> *removeNode = foundNode;
    // if foundNode has a left child, find the in-order predecessor
    // of foundNode
    if (foundNode->left)
    {
        removeNode = foundNode->left;
        while (removeNode->right)
            removeNode = removeNode->right;
    }
    // otherwise, if foundNode has a right child, find the in-order
    // sucessor of foundNode
    else if (foundNode->right)
    {
        removeNode = foundNode->right;
        while (removeNode->left)
            removeNode = removeNode->left;
    }
    // swap
    if (removeNode != foundNode)
    {
        Type temp = removeNode->value;
        removeNode->value = foundNode->value;
        foundNode->value = temp;
    }
    Node<Type> *parent = removeNode->parent;
    bool remove_left = (parent && removeNode == parent->left);
    // now we remove removeNode
    Node<Type> *childNode = (removeNode->left ? removeNode->left :
                             (removeNode->right ? removeNode->right : 0));
    // if removeNode is black and childNode is red, recolour child
    // black (and make remove red to trigger the following case)
    if (!removeNode->red && childNode && childNode->red)
    {
        removeNode->red = true;
        childNode->red = false;
    }
    if (remove_left) parent->left = childNode;
    else if (parent) parent->right = childNode;
    else this->root = childNode;
    if (childNode) childNode->parent = parent;
    removeNode->left = removeNode->right = 0;
    // if removeNode is red, replace it with its child, which must be
    // a leaf child
    if (removeNode->red)
    {
        delete removeNode;
        return true;
    }

    // remaining cases: removeNode is black and childNode is black
    // start by replacing remove with child
    delete removeNode;
    // loop to rebalance
    Node<Type> *current = childNode;
    while (1)
    {
        if (current) parent = current->parent;
        // case 1: childNode is the new root
        // we are done
        if (!parent) return true;
        bool current_left = (parent && current == parent->left);
        Node<Type> *sibling = (current_left ? parent->right : parent->left);
        // case 2: sibling is red
        // reverse the colors of parent and sibling, rotate parent
        // left (if current_left)
        if (sibling->red)
        {
            parent->red = true;
            sibling->red = false;
            if (current_left)
            {
                left_rotate(parent);
                sibling = parent->right;
            }
            else
            {
                right_rotate(parent);
                sibling = parent->left;
            }
        }
        // case 3: parent, sibling, and sibling's children are black
        // repaint S red, set current to parent, and loop
        if (!parent->red &&
            !sibling->red &&
            (!sibling->left || !sibling->left->red) &&
            (!sibling->right || !sibling->right->red))
        {
            sibling->red = true;
            current = parent;
            continue;
        }
        // case 4: parent is red, sibling and sibling's children are black
        // swap colors of sibling and parent, and we are done
        if (parent->red &&
            !sibling->red &&
            (!sibling->left || !sibling->left->red) &&
            (!sibling->right || !sibling->right->red))
        {
            parent->red = false;
            sibling->red = true;
            return true;
        }
        // case 5: sibling is black, sibling's left child is red and
        // right child is black
        // rotate right at sibling, exchange colors of sibling and its
        // new parent (red), and proceed to case 6
        if (!sibling->red)
        {
            if (current_left &&
                (sibling->left && sibling->left->red) &&
                (!sibling->right || !sibling->right->red))
            {
                sibling->red = true;
                sibling->left->red = false;
                right_rotate(sibling);
                sibling = sibling->parent;
            }
            else if (!current_left &&
                     (sibling->right && sibling->right->red) &&
                     (!sibling->left || !sibling->left->red))
            {
                sibling->red = true;
                sibling->right->red = false;
                left_rotate(sibling);
                sibling = sibling->parent;
            }
        }
        // caes 6: sibling is black, sibling's right child is red
        // rotate left at parent, exchange colors of sibling and
        // parent, and make sibling's right child black.  then we're
        // done
        if (!sibling->red)
        {
            if (current_left &&
                (sibling->right && sibling->right->red))
            {
                left_rotate(parent);
                sibling->red = parent->red;
                parent->red = false;
                if (sibling->right) sibling->right->red = false;
                return true;
            }
            else if (!current_left &&
                     (sibling->left && sibling->left->red))
            {
                right_rotate(parent);
                sibling->red = parent->red;
                parent->red = false;
                if (sibling->left) sibling->left->red = false;
                return true;
            }
        }
        cout << "ERROR: remove uncaught case" << endl;
        assert(0);
    }
}

template <typename Type, typename Comp>
RedBlackTreeIterator<Type>
RedBlackTree<Type, Comp>::begin()
{
    if (!this->root) return RedBlackTreeIterator<Type>(0);
    Node<Type> *current = this->root;
    while (current->left)
        current = current->left;
    return RedBlackTreeIterator<Type>(current);
}

template <typename Type, typename Comp>
RedBlackTreeIterator<Type>
RedBlackTree<Type, Comp>::end()
{
    return RedBlackTreeIterator<Type>(0);
}

#ifdef DEBUG
template <typename Type, typename Comp>
string
RedBlackTree<Type, Comp>::to_string()
{
    return _to_string(this->root);
}

template<>
string
RedBlackTree<int, std::less< int > >::_to_string(Node<int> *node)
{
    string result = "[";
    if (node)
    {
        if (node->left)
            result += _to_string(node->left) + " ";
        result = result + (node->red ? "R" : "B") + " " + SSTR(node->value);
        if (node->right)
            result += " " + _to_string(node->right);
    }
    result += "]";
    return result;
}
#endif // DEBUG

template <typename Type, typename Comp>
void
RedBlackTree<Type, Comp>::left_rotate(Node<Type> *node)
{
    Node<Type> *top = node->parent;
    Node<Type> *right_child = node->right;
    // right child of node becomes new top
    if (top)
    {
        if (node == top->left) top->left = right_child;
        else top->right = right_child;
        right_child->parent = top;
    }
    else
    {
        root = right_child;
        right_child->parent = 0;
    }
    // right child's left child becomes node's right child
    node->right = right_child->left;
    if (node->right) node->right->parent = node;
    // node becomes right child's left child
    right_child->left = node;
    node->parent = right_child;
}

template <typename Type, typename Comp>
void
RedBlackTree<Type, Comp>::right_rotate(Node<Type> *node)
{
    Node<Type> *top = node->parent;
    Node<Type> *left_child = node->left;
    // left child of node becomes new top
    if (top)
    {
        if (node == top->right) top->right = left_child;
        else top->left = left_child;
        left_child->parent = top;
    }
    else
    {
        this->root = left_child;
        left_child->parent = 0;
    }
    // left child's right child becomes node's left child
    node->left = left_child->right;
    if (node->left) node->left->parent = node;
    // node becomes left child's right child
    left_child->right = node;
    node->parent = left_child;
}

#endif /* _REDBLACK_H_ */
